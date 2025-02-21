provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  source      = "../modules/networking"
  environment = var.environment
  region      = var.region
}

module "gke" {
  source      =   "../modules/gke"
  project_id  = var.project_id
  environment = var.environment

  # Network dependencies
  vpc_id            = module.networking.vpc_id
  private_subnet_id = module.networking.private_subnet_id
}

module "bastion" {
  source           = "../modules/bastion"
  project_id       = var.project_id
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_id
}

# Create the DNS zone
resource "google_dns_managed_zone" "dns_zone" {
  name        = var.zone_name
  dns_name    = var.dns_name
  description = "${var.dns_zone_description_prefix} ${var.dns_name}"
  visibility  = var.dns_visibility

  lifecycle {
    prevent_destroy = true
  }
}
