resource "google_container_cluster" "primary" {
  name                     = "${var.environment}-gke-cluster"
  location                 = var.cluster_location
  network                  = var.vpc_id
  subnetwork               = var.private_subnet_id
  deletion_protection      = var.cluster_deletion_protection
  remove_default_node_pool = var.cluster_remove_default_node_pool
  initial_node_count       = var.cluster_initial_node_count
  min_master_version       = var.kubernetes_version

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

  database_encryption {
    state    = "ENCRYPTED"
    key_name = var.gke_crypto_key_path
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

data "google_compute_zones" "available" {
  region = var.cluster_location
  status = "UP"
}

resource "google_container_node_pool" "primary_nodes" {
  count          = 3
  name           = "${var.environment}-node-pool${count.index + 1}"
  location       = var.cluster_location
  cluster        = google_container_cluster.primary.name
  node_locations = [data.google_compute_zones.available.names[count.index]] # One zone per node pool
  node_count     = 1

  node_config {
    machine_type = var.machine_type
    image_type   = "COS_CONTAINERD"
    disk_type    = "pd-standard" # Explicitly use standard disks to avoid SSD quota
    disk_size_gb = 30

    service_account = google_service_account.gke_sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.environment
      node_pool   = "pool-${count.index + 1}"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    metadata = {
      disable-legacy-endpoints = "true"
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

data "google_project" "project" {}

resource "google_project_iam_member" "compute_sa_cmek_permission" {
  project = data.google_project.project.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "gke_database_encryption_key" {
  crypto_key_id = var.gke_crypto_key_path
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}
