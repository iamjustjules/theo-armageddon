variable "peering_config" {
  type = object({
    america_network_id = string
    europe_network_id  = string
  })
}

variable "project_id" {
  description = "The Google Cloud project ID"
  default     = "terraform-gcp-justjules"
  type        = string
}