# Google bucket
resource "google_storage_bucket" "my_bucket" {
  name     = var.bucket_name
  location = var.region

  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["http://image-store.com"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

# Public IAM binding for the bucket
resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.my_bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers"
  ]
}

# index.html file
resource "google_storage_bucket_object" "index_html" {
  name   = "index.html"
  bucket = google_storage_bucket.my_bucket.name
  source = "index.html"
  content_type = "text/html"
}

# image files
resource "google_storage_bucket_object" "jandk_png" {
  name   = "Jandk.png"
  bucket = google_storage_bucket.my_bucket.name
  source = "Jandk.png"
  content_type = "image/png"
}

resource "google_storage_bucket_object" "jandn_jpg" {
  name   = "JandN.jpg"
  bucket = google_storage_bucket.my_bucket.name
  source = "JandN.jpg"
  content_type = "image/jpeg"
}

# VPC
resource "google_compute_network" "just_jules_vpc" {
  name                    = "just-jules"
  auto_create_subnetworks = false
}

# subnet
resource "google_compute_subnetwork" "just_jules_subnet" {
  name          = "just-jules-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.just_jules_vpc.id
}

resource "google_compute_instance" "just_jules_vm" {
  name         = "just-jules"
  machine_type = var.machine_type
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.just_jules_vpc.id
    subnetwork = google_compute_subnetwork.just_jules_subnet.id
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "sudo apt-get update && sudo apt-get install -y apache2 && sudo systemctl enable apache2 && sudo systemctl start apache2 && sudo cp /var/www/html/index.html /var/www/html/Jandk.png /var/www/html/JandN.jpg /var/www/html"
}

data "google_secret_manager_secret_version" "my_secret" {
  secret      = "terraform-gcp-secret"
  version     = "latest"
  provider    = google-beta
}