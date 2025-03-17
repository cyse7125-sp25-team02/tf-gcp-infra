variable "region" {
  description = "Default region for resources"
  type        = string
}
variable "dns_project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "dev_project_id" {
  description = "Dev Google Cloud Project ID"
  type        = string
}

variable "prod_project_id" {
  description = "Prod Google Cloud Project ID"
  type        = string
}

variable "org_zone_name" {
  description = "Name for the DNS zone"
  type        = string
}

variable "org_dns_name" {
  description = "DNS name for the zone (gcp.jkops.me)"
  type        = string
}

variable "dev_zone_name" {
  description = "Name for the Dev DNS zone"
  type        = string
}

variable "dev_dns_name" {
  description = "Dev DNS name for the zone (dev.gcp.jkops.me)"
  type        = string
}

variable "prod_zone_name" {
  description = "Name for the Prod DNS zone"
  type        = string
}

variable "prod_dns_name" {
  description = "Prod DNS name for the zone (prod.gcp.jkops.me)"
  type        = string
}
