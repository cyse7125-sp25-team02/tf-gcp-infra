# modules/networking/variables.tf
variable "environment" {
  description = "Environment (dev/prd)"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  type        = string
  default     = "10.0.0.0/18"
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.0.64.0/18"
}

variable "vpc_routing_mode" {
  description = "Routing mode for the VPC"
  type        = string
  default     = "REGIONAL"
}

variable "vpc_auto_create_subnetworks" {
  description = "Auto create subnetworks"
  type        = bool
  default     = false
}

variable "vpc_delete_default_routes_on_create" {
  description = "Delete default routes on create"
  type        = bool
  default     = true
}

variable "private_subnet_ip_google_access" {
  description = "Private IP Google Access"
  type        = bool
  default     = true
}

variable "pod_range_name" {
  description = "Name of the pod range"
  type        = string
  default     = "pod-ranges"
}

variable "pod_ip_cidr" {
  description = "CIDR for the pod range"
  type        = string
  default     = "10.0.128.0/17"
}

variable "service_range_name" {
  description = "Name of the service range"
  type        = string
  default     = "service-ranges"
}

variable "service_ip_cidr" {
  description = "CIDR for the service range"
  type        = string
  default     = "10.1.0.0/16"
}

variable "nat_ip_option" {
  description = "NAT IP allocation option"
  type        = string
  default     = "AUTO_ONLY"
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Source subnetwork IP ranges to NAT"
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

variable "ingress_direction" {
  description = "Ingress direction"
  type        = string
  default     = "INGRESS"
}

variable "firewall_priority" {
  description = "Firewall priority"
  type        = number
  default     = 1000
}

variable "tcp_protocol" {
  description = "TCP protocol"
  type        = string
  default     = "tcp"
}

variable "allow_bastion_ports" {
  description = "Ports to allow for bastion"
  type        = list(string)
  default     = ["22"]
}

variable "firewall_bastion_source_range" {
  description = "Source range for bastion firewall rule"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "firewall_gke_master_ports" {
  description = "Ports to allow for GKE master"
  type        = list(string)
  default     = ["80", "443", "10250"]
}

variable "firewall_gke_master_source_range" {
  description = "Source range for GKE master firewall rule"
  type        = list(string)
  default     = ["172.16.0.0/28"]
}
