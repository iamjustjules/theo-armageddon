terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "google_compute_network" "europe_network" {
  name                    = var.config.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "europe_subnet" {
  name                     = var.config.subnet_name
  network                  = google_compute_network.europe_network.id
  ip_cidr_range            = var.config.subnet_cidr
  region                   = var.config.region
  private_ip_google_access = true
}

resource "google_compute_firewall" "europe_http" {
  name    = "europe-http"
  network = google_compute_network.europe_network.id

  allow {
    protocol = "tcp"
    ports    = var.config.allowed_ports
  }

  source_ranges = var.config.ip_cidr_ranges
  target_tags   = var.config.tags
}

resource "google_compute_instance" "europe_vm" {
  depends_on   = [google_compute_subnetwork.europe_subnet]
  name         = var.config.vm_name
  machine_type = "e2-medium"
  zone         = var.config.zone

  boot_disk {
    initialize_params {
      image = var.config.image_family
    }
  }

  network_interface {
    network    = google_compute_network.europe_network.id
    subnetwork = google_compute_subnetwork.europe_subnet.id
    access_config {
      // Not assigned a public IP
    }
  }
 
  metadata = {
    startup-script = file("${path.module}/startup-script.sh")
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  tags = var.config.tags
}

module "europe_vpn" {
  source = "../vpn"

  vpn_gateway_name        = "europe-vpn-gateway"
  network_id              = google_compute_network.europe_network.id
  region                  = var.config.region
  vpn_ip_name             = "europe-vpn-ip"
  vpn_tunnel_name         = "europe-to-asia-tunnel"
  peer_ip                 = var.peer_ip
  shared_secret           = var.vpn_shared_secret
  local_traffic_selector  = var.local_traffic_selector
  remote_traffic_selector = var.remote_traffic_selector
  vpn_route_name          = "europe-to-asia-route"
}

output "network_id" {
  value = google_compute_network.europe_network.id
}

output "europe_vpn_ip_address" {
  value = module.europe_vpn.vpn_ip_address
}

output "europe_vm_internal_ip" {
  description = "Internal IP address of the Europe VM"
  value       = google_compute_instance.europe_vm.network_interface[0].network_ip
}

# Google Bucket static site and materials
resource "google_storage_bucket" "web_bucket" {
  name          = "european-web-bucket"
  location      = var.config.region
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_object" "index_html" {
  name         = "index.html"
  bucket       = google_storage_bucket.web_bucket.name
  source       = "index.html"
  content_type = "text/html"
}

resource "google_storage_bucket_object" "image1" {
  name         = "JandK.png"
  bucket       = google_storage_bucket.web_bucket.name
  source       = "JandK.png"
  content_type = "image/png"
}

resource "google_storage_bucket_object" "image2" {
  name         = "JandN.jpg"
  bucket       = google_storage_bucket.web_bucket.name
  source       = "JandN.jpg"
  content_type = "image/jpeg"
}

# HTTP(S) Load Balancer and Backend Bucket
resource "google_compute_backend_bucket" "gcs_backend" {
  name        = "europe-static-content"
  bucket_name = google_storage_bucket.web_bucket.name
  enable_cdn  = true
}

resource "google_compute_url_map" "url_map" {
  name            = "web-map"
  default_service = google_compute_backend_bucket.gcs_backend.self_link
}

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "http-content-rule"
  target     = google_compute_target_http_proxy.http_proxy.self_link
  port_range = "80"
}

# Google Cloud Armor setup
resource "google_compute_security_policy" "allow_us_only" {
  name = "allow-us-only-policy"

  rule {
    action   = "allow"
    priority = 1000
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.american_ip_ranges
      }
    }
    description = "Allow traffic from specific American IP ranges"
  }

  rule {
    action   = "deny"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default rule that denies all other traffic"
  }
}

resource "google_compute_target_http_proxy" "http_proxy_with_armor" {
  name               = "http-lb-proxy-armor"
  url_map            = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "default_with_armor" {
  name       = "http-content-rule-armor"
  target     = google_compute_target_http_proxy.http_proxy_with_armor.self_link
  port_range = "80"
}

output "website_url" {
  description = "URL of the static website hosted on Google Cloud Storage."
  value = "http://${google_storage_bucket.web_bucket.name}.storage.googleapis.com/index.html"
}
