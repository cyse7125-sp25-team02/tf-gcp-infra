resource "google_container_cluster" "primary" {
  name                     = "${var.environment}-gke-cluster"
  location                 = var.cluster_location
  network                  = var.vpc_id
  subnetwork               = var.private_subnet_id
  deletion_protection      = var.cluster_deletion_protection
  remove_default_node_pool = var.cluster_remove_default_node_pool
  initial_node_count       = var.cluster_initial_node_count

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.bastion_host_cidr # Public subnet CIDR where bastion host resides(networking module)
      display_name = "Bastion Host"
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  release_channel {
    channel = "REGULAR"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "service-ranges"
  }

  resource_labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.environment}-node-pool"
  location = var.cluster_location
  cluster  = google_container_cluster.primary.name

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = var.machine_type
    image_type   = "COS_CONTAINERD"

    service_account = google_service_account.gke_sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.environment
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }

  depends_on = [
    google_container_cluster.primary
  ]
}

resource "google_service_account" "gke_sa" {
  account_id   = "${var.environment}-gke-sa"
  display_name = "GKE Service Account"
}
