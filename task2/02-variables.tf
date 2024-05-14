variable "project_id" {
  description = "The Google Cloud project ID"
  default     = "terraform-gcp-justjules"
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket."
  default     = "terraform-gcp-justjules"
}

variable "region" {
  description = "The region for cloud resources"
  default     = "us-central1"
}

variable "zone" {
  description = "The zone for the VM"
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The type of the machine"
  default     = "e2-medium"
}

variable "credentials" {
  description = "The path to the service account key file."
  default     = "C:\\Users\\Julie\\OneDrive\\Documents\\Career\\Tools\\BlackManosphere\\01-GCP\\20240511/terraform-gcp-justjules-793f0d4e098d.json"
}
