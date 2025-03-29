variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "gcs_bucket_names" {
  type    = set(string)
  default = ["csye7125-trace-data","db-backup-schema"]
}

variable "ksa_mappings" {
  type = map(object({
    namespace          = string
    service_account_name = string
  }))
  default = {
    "ksa1" = { namespace = "api-server-app", service_account_name = "api-server-ksa" }
    "ksa2" = { namespace = "db-backup-operator", service_account_name = "db-backup-operator-ksa" }
  }
}
