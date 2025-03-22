variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket for api-server"
  type        = string
  default     = "csye7125-trace-data"
}

variable "k8s_namespace" {
  description = "The Kubernetes namespace for the api-server"
  type        = string
  default     = "api-server"
}

variable "k8s_service_account_name" {
  description = "The name of the Kubernetes Service Account"
  type        = string
  default     = "api-server-ksa"
}
