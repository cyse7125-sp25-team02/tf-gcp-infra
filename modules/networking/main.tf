resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = var.vpc_auto_create_subnetworks
  routing_mode            = var.vpc_routing_mode
}

resource "google_compute_subnetwork" "private" {
  name                     = "${var.environment}-private-subnet"
  ip_cidr_range            = var.private_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = var.private_subnet_ip_google_access

  secondary_ip_range {
    range_name    = var.pod_range_name
    ip_cidr_range = var.pod_ip_cidr
  }

  secondary_ip_range {
    range_name    = var.service_range_name
    ip_cidr_range = var.service_ip_cidr
  }
}

resource "google_compute_subnetwork" "public" {
  name          = "${var.environment}-public-subnet"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_router" "router" {
  name    = "${var.environment}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = var.nat_ip_option
  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  subnetwork {
    name                    = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_firewall" "allow_bastion_ssh" {
  name      = "${var.environment}-allow-bastion-ssh"
  network   = google_compute_network.vpc.id
  direction = var.ingress_direction
  priority  = var.firewall_priority

  allow {
    protocol = var.tcp_protocol
    ports    = var.allow_bastion_ports
  }

  target_tags   = ["bastion"]
  source_ranges = var.firewall_bastion_source_range
}

# Add internal communication firewall rule
resource "google_compute_firewall" "internal" {
  name    = "${var.environment}-allow-internal"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = [
    "10.0.0.0/18", # Private subnet
    "10.0.64.0/18" # Public subnet
  ]
}

resource "google_compute_firewall" "allow_health_checks_egress" {
  name               = "${var.environment}-allow-health-checks-egress"
  network            = google_compute_network.vpc.id
  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["0.0.0.0/0"] # Allow outbound internet access
  target_tags        = ["allow-health-checks"]

  allow {
    protocol = "tcp"
  }
}


