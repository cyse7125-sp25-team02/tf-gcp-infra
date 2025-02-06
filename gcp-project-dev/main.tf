provider "google" {
  project = var.project_id
  region  = var.region
}

# Create the DNS zone
resource "google_dns_managed_zone" "dns_zone" {
  name        = var.zone_name
  dns_name    = var.dns_name
  description = "Managed DNS zone for ${var.dns_name}"
  visibility  = "public"

  lifecycle {
    prevent_destroy = true
  }
}
