variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
  default     = "silicon-works-449817-n7"
}

variable "region" {
  default = "us-east1"
}

variable "environment" {
  description = "The environment for the project (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
