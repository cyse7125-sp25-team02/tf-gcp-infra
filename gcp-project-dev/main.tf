provider "google" {
  project = var.project_id
  region  = var.region
}

module "cmek" {
  source           = "../modules/cmek"
  key_ring_name    = "csye7125"
  crypto_key_names = ["gke_cluster", "sops"]
}

module "networking" {
  source      = "../modules/networking"
  environment = var.environment
  region      = var.region
}

module "gke" {
  source      = "../modules/gke"
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

module "workload_identity" {
  source      = "../modules/workload-identity"
  project_id  = var.project_id
  environment = var.environment
}
