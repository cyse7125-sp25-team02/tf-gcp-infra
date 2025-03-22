# Create the Google Service Account (GSA) for the api-server
resource "google_service_account" "api_server_gcs" {
  account_id   = "${var.environment}-api-server-gcs"
  display_name = "API Server GCS Service Account"
  project      = var.project_id
}

# Grant the GSA permissions to access the GCS bucket
resource "google_storage_bucket_iam_member" "gcs_access" {
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectAdmin" # Full control over objects in the bucket
  member = "serviceAccount:${google_service_account.api_server_gcs.email}"
}

# Bind the GSA to the KSA using Workload Identity (roles/iam.workloadIdentityUser)
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.api_server_gcs.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_namespace}/${var.k8s_service_account_name}]"
}
