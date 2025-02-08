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
