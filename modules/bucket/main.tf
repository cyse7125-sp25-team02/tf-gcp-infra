# Create multiple GCS buckets
resource "google_storage_bucket" "buckets" {
  for_each                    = var.gcs_bucket_names
  project                     = var.project_id
  name                        = each.value
  location                    = "US"
  uniform_bucket_level_access = true

  # Prevent Terraform from destroying the bucket
  lifecycle {
    prevent_destroy = true
  }
}
