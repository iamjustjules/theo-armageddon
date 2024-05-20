# American Networks and Subnetworks
resource "google_compute_network" "american1_network" {
  name                    = "american-network1"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "american1_subnet" {
  name          = "american-subnet1"
  ip_cidr_range = "172.16.0.0/24"
  region        = var.american1_region
  network       = google_compute_network.american1_network.id
}

# Peering between American and European Networks
resource "google_compute_network_peering" "us_to_eu_peering1" {
  name         = "us-to-eu-peering1"
  network      = google_compute_network.american1_network.id
  peer_network = google_compute_network.european_network.id
}

resource "google_compute_network_peering" "eu_to_us_peering1" {
  name         = "eu-to-us-peering1"
  network      = google_compute_network.european_network.id
  peer_network = google_compute_network.american1_network.id
}

resource "google_compute_firewall" "internal_http1" {
  name    = "internal-http1"
  network = google_compute_network.american1_network.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }
  source_tags =  ["vpn"]
  source_ranges = ["172.16.0.0/24","10.157.0.0/24", "35.235.240.0/20"]
    target_tags = ["us-instance1","iap-ssh-allowed"]
}

resource "google_compute_instance" "us-instance1" {
  depends_on = [ google_compute_subnetwork.american1_subnet ]
  name         = "us-instance1"
  machine_type = var.instance_type
  zone         = "${var.american1_region}-b"

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network = google_compute_network.american1_network.id
    subnetwork = google_compute_subnetwork.american1_subnet.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }

  tags = ["us1", "vpn", "iam-ssh-allowed"]
}

resource "google_compute_vpn_gateway" "american1_vpn_gateway" {
  name    = "american-vpn-gateway"
  region  = var.american1_region
  network = google_compute_network.american1_network.id
}

resource "google_compute_address" "american1_vpn_gateway_ip" {
  name   = "american-vpn-gateway-ip"
  region = var.american1_region
}

resource "google_compute_forwarding_rule" "american1_esp" {
  name        = "american-esp"
  region      = var.american1_region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.american1_vpn_gateway_ip.address
  target      = google_compute_vpn_gateway.american1_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_forwarding_rule" "american1_udp500" {
  name        = "american-udp500"
  region      = var.american1_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.american1_vpn_gateway_ip.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.american1_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_forwarding_rule" "american1_udp4500" {
  name        = "american-udp4500"
  region      = var.american1_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.american1_vpn_gateway_ip.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.american1_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_vpn_tunnel" "american1_to_europe_tunnel" {
  name                    = "american-to-europe-tunnel"
  region                  = var.american1_region
  target_vpn_gateway      = google_compute_vpn_gateway.american1_vpn_gateway.id
  peer_ip                 = google_compute_address.european_vpn_gateway_ip.address
  shared_secret           = var.vpn_shared_secret
  ike_version             = 2
  local_traffic_selector  = ["192.168.11.0/24"]
  remote_traffic_selector = ["10.150.11.0/24"]
  depends_on = [
    google_compute_forwarding_rule.american1_esp,
    google_compute_forwarding_rule.american1_udp500
  ]
}
