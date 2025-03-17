provider "google" {
  alias   = "org"
  project = var.dns_project_id
  region  = var.region
}

# Provider for Dev project
provider "google" {
  alias   = "dev"
  project = var.dev_project_id
  region  = var.region
}

# Provider for Prod project
provider "google" {
  alias   = "prod"
  project = var.prod_project_id
  region  = var.region
}

# Create the DNS zone
resource "google_dns_managed_zone" "org_dns_zone" {
  provider    = google.org
  name        = var.org_zone_name
  dns_name    = var.org_dns_name
  description = "Managed DNS zone for ${var.org_dns_name}"
  visibility  = "public"

  lifecycle {
    prevent_destroy = true
  }
}

# Create the DNS zone
resource "google_dns_managed_zone" "dev_dns_zone" {
  provider    = google.dev
  name        = var.dev_zone_name
  dns_name    = var.dev_dns_name
  description = "Managed DNS zone for ${var.dev_dns_name}"
  visibility  = "public"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_dns_managed_zone" "prod_dns_zone" {
  provider    = google.prod
  name        = var.prod_zone_name
  dns_name    = var.prod_dns_name
  description = "Managed DNS zone for ${var.prod_dns_name}"
  visibility  = "public"

  lifecycle {
    prevent_destroy = true
  }
}

# NS record for dev subdomain in org zone (manually input via variable)
resource "google_dns_record_set" "dev_ns_record" {
  provider     = google.org
  managed_zone = google_dns_managed_zone.org_dns_zone.name
  name         = var.dev_dns_name
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.dev_dns_zone.name_servers
  depends_on   = [google_dns_managed_zone.org_dns_zone]
}

# NS record for prod subdomain in org zone
resource "google_dns_record_set" "prod_ns_record" {
  provider     = google.org
  managed_zone = google_dns_managed_zone.org_dns_zone.name
  name         = var.prod_dns_name
  type         = "NS"
  ttl          = 300
  rrdatas      = google_dns_managed_zone.prod_dns_zone.name_servers
  depends_on   = [google_dns_managed_zone.org_dns_zone]
}
