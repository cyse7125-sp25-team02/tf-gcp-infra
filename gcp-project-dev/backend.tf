terraform {
  backend "gcs" {
    bucket = "csye7125-terraform-backend"
    prefix = "terraform/state"
  }
}
