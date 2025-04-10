variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/prd)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}


variable "vpc_id" {
  description = "VPC network ID where the cluster will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "Subnet ID where the cluster will be created"
  type        = string
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}
