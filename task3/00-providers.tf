provider "google" {
  credentials = var.credentials
  project     = var.project_id
  region      = var.european_region
}

provider "google-beta" {
  credentials = var.credentials
  project     = var.project_id
  region      = var.european_region
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5"
    }
  }

  required_version = ">= 0.12"
}