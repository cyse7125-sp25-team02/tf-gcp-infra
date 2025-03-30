provider "google" {
  project = var.project_id
  region  = var.region
}

module "bucket" {
  source      = "../modules/bucket"
  project_id  = var.project_id
  environment = var.environment
}

module "cmek" {
  source           = "../modules/cmek"
  key_ring_name    = "csye7125"
  crypto_key_names = ["gke_cluster", "sops"]
}
