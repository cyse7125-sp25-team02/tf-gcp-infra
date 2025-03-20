variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "kubernetes_version" {
  description = "The Kubernetes version for the GKE cluster"
  type        = string
  default     = "1.30.9-gke.1127000"

}

variable "environment" {
  description = "Environment name (dev/prd)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "cluster_location" {
  description = "The GCP location(region or zone) for the cluster"
  type        = string
  default     = "us-east1"
}

variable "vpc_id" {
  description = "VPC network ID where the cluster will be created"
  type        = string
}

variable "private_subnet_id" {
  description = "Subnet ID where the cluster will be created"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master nodes"
  type        = string
  default     = "172.16.0.0/28"
}

variable "machine_type" {
  description = "Machine type for the GKE nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "cluster_deletion_protection" {
  description = "Enable deletion protection for the GKE cluster"
  type        = bool
  default     = false
}

variable "cluster_remove_default_node_pool" {
  description = "Remove the default node pool"
  type        = bool
  default     = true
}

variable "cluster_initial_node_count" {
  description = "GKE cluster initial number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for the GKE cluster"
  type        = bool
  default     = true
}

variable "enable_private_nodes" {
  description = "Enable private nodes for the GKE cluster"
  type        = bool
  default     = true
}

variable "bastion_host_cidr" {
  description = "CIDR block for the bastion host"
  type        = string
  default     = "10.0.64.0/18"
}

variable "gke_crypto_key_path" {
  description = "The path to the KMS key used for encrypting the GKE database"
  type        = string
  default     = "projects/silicon-works-449817-n7/locations/us-east1/keyRings/csye7125/cryptoKeys/gke_cluster"

}
