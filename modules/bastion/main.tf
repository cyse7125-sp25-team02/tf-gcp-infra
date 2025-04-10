# modules/bastion/main.tf
resource "google_compute_instance" "bastion" {
  name         = "${var.environment}-bastion"
  machine_type = "e2-highcpu-2"
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
    apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin git vim

    # Set HOME explicitly for root
    export HOME=/root
    mkdir -p $HOME/.kube

    # Wait for GKE cluster to be ready
    echo "Waiting for GKE cluster ${var.gke_cluster_name} to be ready..."
    until gcloud container clusters describe ${var.gke_cluster_name} --zone us-east1 | grep -q "status: RUNNING"; do
      echo "Cluster not ready yet, waiting 10 seconds..."
      sleep 10
    done
    echo "GKE cluster is ready!"

    # Authenticate to GKE cluster using EXTERNAL IP
    echo "Authenticating to GKE cluster with external IP: ${var.environment}-gke-cluster"
    gcloud container clusters get-credentials ${var.environment}-gke-cluster --zone us-east1 || {
        echo "gcloud get-credentials (external IP) failed"
        exit 1
    }

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

    # Create admin user if it doesn't exist
    if ! id "admin" >/dev/null 2>&1; then
        useradd -m -s /bin/bash admin
        echo "admin user created"
    fi

    # Persist kubeconfig in admin's home directory
    echo "Persisting external IP kubeconfig for admin..."
    mkdir -p /home/admin/.kube
    cp /root/.kube/config /home/admin/.kube/config || { echo "Failed to copy kubeconfig"; exit 1; }
    chown admin:admin /home/admin/.kube/config
    chmod 600 /home/admin/.kube/config

    # Set KUBECONFIG for all users to admin's config
    echo "export KUBECONFIG=/home/admin/.kube/config" > /etc/profile.d/kubeconfig.sh
    chmod +x /etc/profile.d/kubeconfig.sh
    source /etc/profile.d/kubeconfig.sh
    export KUBECONFIG=/home/admin/.kube/config

    # Verify connectivity
    echo "Testing kubectl connectivity with external IP..."
    kubectl version --client || { echo "kubectl client failed"; exit 1; }
    kubectl get nodes || { echo "kubectl cannot list nodes (external IP)"; exit 1; }
    echo "kubectl connected successfully with external IP"

    # Install Istio
    echo "Installing Istio..."
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.25.1 sh -
    mv istio-1.25.1 /opt/istio-1.25.1 || { echo "Failed to move Istio"; exit 1; }
    cd /opt/istio-1.25.1 || { echo "Failed to cd into Istio dir"; exit 1; }
    echo "export PATH=$(pwd)/bin:\$PATH" > /etc/profile.d/istio.sh
    chmod +x /etc/profile.d/istio.sh
    export PATH="/opt/istio-1.25.1/bin:$PATH"
    ln -s /opt/istio-1.25.1/bin/istioctl /usr/local/bin/istioctl

    # Verify istioctl
    echo "istioctl installed successfully: $(istioctl version --short)"
    istioctl version || { echo "istioctl cannot connect (external IP)"; exit 1; }

    # Install Istio with custom profile
    cat << 'CUSTOM_PROFILE' > /tmp/custom-profile.yaml
    ${file("${path.module}/custom-profile.yaml")}
    CUSTOM_PROFILE

    echo "Installing Istio custom profile..."
    istioctl install -f /tmp/custom-profile.yaml -y || { 
        echo "Istio install failed - dumping diagnostics"
        kubectl cluster-info
        exit 1
    }

    # Set up INTERNAL IP config for SSH
    echo "Generating internal IP kubeconfig for SSH sessions..."
    gcloud container clusters get-credentials ${var.environment}-gke-cluster --zone us-east1 --internal-ip || {
        echo "gcloud get-credentials (internal IP) failed"
        exit 1
    }

    # Store internal IP config separately
    mv /root/.kube/config /root/.kube/config-internal || { echo "Failed to move internal IP kubeconfig"; exit 1; }
    chmod 600 /root/.kube/config-internal

    # Restore external IP config for root
    cp /home/admin/.kube/config /root/.kube/config

    # Instructions for SSH users
    cat << 'SSH_INSTRUCTIONS' > /root/README-kubeconfig.txt
    To use the internal IP for kubectl commands during SSH sessions:
    export KUBECONFIG=/root/.kube/config-internal
    SSH_INSTRUCTIONS

    # Deploy Istio addons for dashboard
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/addons/prometheus.yaml || echo "Failed to apply Prometheus"
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/addons/grafana.yaml || echo "Failed to apply Grafana"
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.25/samples/addons/kiali.yaml || echo "Failed to apply Kiali"

    echo "Setup complete. Use 'export KUBECONFIG=/root/.kube/config-internal' for internal IP access via SSH."
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

