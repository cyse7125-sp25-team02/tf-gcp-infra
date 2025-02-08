# modules/networking/outputs.tf
output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = google_compute_subnetwork.private.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = google_compute_subnetwork.public.id
}
