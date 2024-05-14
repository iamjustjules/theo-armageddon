# European VPC
resource "google_compute_network" "european_vpc" {
  name                    = "european-vpc"
  auto_create_subnetworks = false
}

# Subnet for Europe
resource "google_compute_subnetwork" "european_subnet" {
  name          = "european-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.european_region
  network       = google_compute_network.european_vpc.id
  private_ip_google_access = true
}

# American VPCs
resource "google_compute_network" "american_vpc1" {
  name                    = "american-vpc1"
  auto_create_subnetworks = false
}

resource "google_compute_network" "american_vpc2" {
  name                    = "american-vpc2"
  auto_create_subnetworks = false
}

# Subnets for American VPCs
resource "google_compute_subnetwork" "american_subnet1" {
  name          = "american-subnet1"
  ip_cidr_range = "172.16.0.0/24"
  region        = var.american_region1
  network       = google_compute_network.american_vpc1.id
}

resource "google_compute_subnetwork" "american_subnet2" {
  name          = "american-subnet2"
  ip_cidr_range = "172.16.1.0/24"
  region        = var.american_region2
  network       = google_compute_network.american_vpc2.id
}

# Asia Pacific VPC and Subnet
resource "google_compute_network" "asia_pacific_vpc" {
  name                    = "asia-pacific-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "asia_pacific_subnet" {
  name          = "asia-pacific-subnet"
  ip_cidr_range = "192.168.0.0/24"
  region        = var.asia_pacific_region
  network       = google_compute_network.asia_pacific_vpc.id
}

# VPN and Firewall rules would be defined similarly, using Google's VPN and firewall resources

data "google_secret_manager_secret_version" "my_secret" {
  secret      = "terraform-gcp-secret"
  version     = "latest"
  provider    = google-beta
}