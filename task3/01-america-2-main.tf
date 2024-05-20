# AMerican 2nd network and subnetworks
resource "google_compute_network" "american2_network" {
  name                    = "american2-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "american2_subnet" {
  name          = "american-subnet2"
  ip_cidr_range = "172.16.1.0/24"
  region        = var.american2_region
  network       = google_compute_network.american2_network.id
}

# Peering between American and European Networks
resource "google_compute_network_peering" "us_to_eu_peering2" {
  name         = "us-to-eu-peering2"
  network      = google_compute_network.american2_network.id
  peer_network = google_compute_network.european_network.id
}

resource "google_compute_network_peering" "eu_to_us_peering2" {
  name         = "eu-to-us-peering2"
  network      = google_compute_network.european_network.id
  peer_network = google_compute_network.american2_network.id
}

resource "google_compute_firewall" "internal_http2" {
  name    = "internal-http2"
  network = google_compute_network.american2_network.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80","22"]
  }
  source_tags =  ["vpn"]
  source_ranges = ["10.157.0.0/24", "35.235.240.0/20"]
  target_tags = ["us-instance2","iap-ssh-allowed"]
}

resource "google_compute_instance" "us-instance2" {
  depends_on = [ google_compute_subnetwork.american2_subnet ]
  name         = "us-instance2"
  machine_type = var.instance_type
  zone         = "${var.american2_region}-b"
  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network = google_compute_network.american2_network.id
    subnetwork = google_compute_subnetwork.american2_subnet.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }

  tags = ["us2", "vpn", "iam-ssh-allowed"]
}

resource "google_compute_vpn_gateway" "american2_vpn_gateway" {
  name    = "asia-vpn-gateway"
  region  = var.american2_region
  network = google_compute_network.american2_network.id
}

resource "google_compute_address" "american2_vpn_gateway_ip" {
  name   = "asia-vpn-gateway-ip"
  region = var.american2_region
}

resource "google_compute_forwarding_rule" "american2_esp" {
  name        = "asia-esp"
  region      = var.american2_region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.american2_vpn_gateway_ip.address
  target      = google_compute_vpn_gateway.american2_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_forwarding_rule" "american2_udp500" {
  name        = "asia-udp500"
  region      = var.american2_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.american2_vpn_gateway_ip.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.american2_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_forwarding_rule" "american2_udp4500" {
  name        = "asia-udp4500"
  region      = var.american2_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.american2_vpn_gateway_ip.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.american2_vpn_gateway.self_link
  depends_on = [ google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_vpn_tunnel" "american2_to_europe_tunnel" {
  name                    = "asia-to-europe-tunnel"
  region                  = var.american2_region
  target_vpn_gateway      = google_compute_vpn_gateway.american2_vpn_gateway.id
  peer_ip                 = google_compute_address.european_vpn_gateway_ip.address
  shared_secret           = var.vpn_shared_secret
  ike_version             = 2
  local_traffic_selector  = ["192.168.11.0/24"]
  remote_traffic_selector = ["10.150.11.0/24"]
  depends_on = [
    google_compute_forwarding_rule.american2_esp,
    google_compute_forwarding_rule.american2_udp500
  ]
}
