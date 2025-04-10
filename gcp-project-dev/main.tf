provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source      = "../modules/networking"
  environment = var.environment
  region      = var.region
}

module "gke" {
  source      = "../modules/gke"
  project_id  = var.project_id
  environment = var.environment

  # Network dependencies
  vpc_id            = module.networking.vpc_id
  private_subnet_id = module.networking.private_subnet_id
}

module "bastion" {
  source           = "../modules/bastion"
  project_id       = var.project_id
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_id
  gke_cluster_name = module.gke.cluster_name
  depends_on       = [module.gke]
}

# Fetch existing buckets using a data source
data "google_storage_bucket" "buckets" {
  for_each = var.gcs_bucket_names
  name     = each.value
}

# Create the Google Service Account (GSA) for the api-server
resource "google_service_account" "api_server_gcs" {
  account_id   = "${var.environment}-api-server-gcs"
  display_name = "API Server GCS Service Account"
  project      = var.project_id
}

# Grant the GSA permissions to access the GCS bucket
resource "google_storage_bucket_iam_member" "gcs_access" {
  for_each = var.gcs_bucket_names
  bucket   = data.google_storage_bucket.buckets[each.value].name
  role     = "roles/storage.objectAdmin" # Full control over objects in the bucket
  member   = "serviceAccount:${google_service_account.api_server_gcs.email}"
}

# Bind the GSA to the KSA using Workload Identity (roles/iam.workloadIdentityUser)
resource "google_service_account_iam_member" "workload_identity_binding" {
  for_each           = var.ksa_mappings
  service_account_id = google_service_account.api_server_gcs.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${each.value.namespace}/${each.value.service_account_name}]"
}

resource "google_project_iam_member" "gmp_collector_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.api_server_gcs.email}"
}
