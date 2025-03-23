# modules/bastion/main.tf
resource "google_compute_instance" "bastion" {
  name         = "${var.environment}-bastion"
  machine_type = "e2-micro"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = var.public_subnet_id
    access_config {
      // Ephemeral public IP
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
  # Install necessary tools for GKE access
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y \
      kubectl \
      google-cloud-sdk-gke-gcloud-auth-plugin \
      git \
      tinyproxy \
      vim \
      tmux

    # Install SOPS
    curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64
    mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops
    chmod +x /usr/local/bin/sops
    sops --version

    # Install Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod +x get_helm.sh
    ./get_helm.sh
    helm version
    
    # Configure tinyproxy for kubectl proxy
    echo "Allow localhost" >> /etc/tinyproxy/tinyproxy.conf
    systemctl restart tinyproxy
  EOF

  tags = ["bastion"]

  service_account {
    email  = google_service_account.bastion_sa.email
    scopes = ["cloud-platform"]
  }
}

# Create dedicated service account for bastion
# GKE Service Account IAM
resource "google_service_account" "bastion_sa" {
  account_id   = "${var.environment}-bastion-sa"
  display_name = "Bastion Host Service Account"
}

# Bastion Service Account IAM
resource "google_project_iam_member" "bastion_sa_roles" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/container.admin",
    "roles/compute.networkViewer",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/iam.serviceAccountAdmin"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.bastion_sa.email}"
}

