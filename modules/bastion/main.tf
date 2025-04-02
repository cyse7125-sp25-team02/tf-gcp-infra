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
      vim \

    # Set HOME explicitly for gcloud and kubectl
    export HOME=/root
    mkdir -p $HOME/.kube  # Ensure .kube directory exists

    # Authenticate to GKE cluster
    echo "Authenticating to GKE cluster: ${var.environment}-gke-cluster"
    gcloud container clusters get-credentials ${var.environment}-gke-cluster --zone us-east1 --internal-ip

    # Persist kubeconfig system-wide
    echo "Persisting kubeconfig system-wide..."
    mkdir -p /etc/kubernetes
    cp /root/.kube/config /etc/kubernetes/admin.conf || { echo "Failed to copy kubeconfig"; exit 1; }
    chmod 644 /etc/kubernetes/admin.conf  # Readable by all users
    echo "export KUBECONFIG=/etc/kubernetes/admin.conf" > /etc/profile.d/kubeconfig.sh
    chmod +x /etc/profile.d/kubeconfig.sh
    source /etc/profile.d/kubeconfig.sh

    # Apply KUBECONFIG immediately in this script
    export KUBECONFIG=/etc/kubernetes/admin.conf

    # Verify connectivity
    echo "Testing kubectl connectivity..."
    kubectl version --client || { echo "kubectl cannot connect to the cluster"; exit 1; }
    echo "kubectl connected successfully"

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
    
    # Install Istio
    echo "Installing Istio..."
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.25.1 sh -
    mv istio-1.25.1 /opt/istio-1.25.1 || { echo "Failed to move Istio to /opt"; exit 1; }
    cd /opt/istio-1.25.1 || { echo "Failed to cd into /opt/istio-1.25.1"; exit 1; }

    # Persist the PATH change system-wide
    echo "export PATH=$(pwd)/bin:\$PATH" > /etc/profile.d/istio.sh
    chmod +x /etc/profile.d/istio.sh

    # Apply the PATH change immediately in this script
    export PATH="/opt/istio-1.25.1/bin:$PATH"

    # Fix permissions for the Istio directory to allow all users to access it
    chmod -R 755 /opt/istio-1.25.1
    ln -s /opt/istio-1.25.1/bin/istioctl /usr/local/bin/istioctl

    # Verify istioctl is available
    if ! command -v istioctl >/dev/null 2>&1; then
      echo "istioctl not found in PATH after installation"
      exit 1
    fi
    echo "istioctl installed successfully: $(istioctl version --short)"

    # Write the custom-profile.yaml from metadata to a file
    cat << 'CUSTOM_PROFILE' > /tmp/custom-profile.yaml
    ${file("${path.module}/custom-profile.yaml")}
    CUSTOM_PROFILE

    # Install Istio with the custom profile
    istioctl install -f /tmp/custom-profile.yaml -y || { echo "Istio custom profile installation failed"; exit 1; }

    # Deploy Istio addons for dashboard
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/addons/prometheus.yaml || echo "Failed to apply Prometheus"
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/addons/grafana.yaml || echo "Failed to apply Grafana"
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/addons/kiali.yaml || echo "Failed to apply Kiali"
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

