variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "environment" {
  description = "Dev Project Environment"
  type        = string
}

variable "region" {
  description = "Default region for resources"
  type        = string
}

variable "zone_name" {
  description = "Name for the DNS zone"
  type        = string
}

variable "dns_name" {
  description = "DNS name for the zone (dev.gcp.jkops.me)"
  type        = string
}

variable "dns_visibility" {
  description = "Visibility of the DNS zone"
  type        = string
}

variable "dns_zone_description_prefix" {
  description = "Description prefix for the DNS zone"
  type        = string
}

variable "gcs_bucket_names" {
  type    = set(string)
  default = ["csye7125-trace-data", "db-backup-schema"]
}

variable "ksa_mappings" {
  type = map(object({
    namespace            = string
    service_account_name = string
  }))
  default = {
    "ksa1" = { namespace = "api-server-app", service_account_name = "api-server-ksa" }
    "ksa2" = { namespace = "db-backup-operator", service_account_name = "db-backup-operator-ksa" }
  }
}
