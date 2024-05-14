variable "project_id" {
  description = "The Google Cloud project ID."
  default = "terraform-gcp-justjules"
}

variable "european_region" {
  description = "The European region for the resources."
  default     = "europe-west1"
}

variable "american_region1" {
  description = "First American region for subsidiary."
  default     = "us-west1"
}

variable "american_region2" {
  description = "Second American region for subsidiary."
  default     = "us-east1"
}

variable "asia_pacific_region" {
  description = "Asia Pacific region."
  default     = "asia-east1"
}
variable "credentials" {
  description = "The path to the service account key file."
  default     = "C:\\Users\\Julie\\OneDrive\\Documents\\Career\\Tools\\BlackManosphere\\01-GCP\\20240511/terraform-gcp-justjules-793f0d4e098d.json"
}