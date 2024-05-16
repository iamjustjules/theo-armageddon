variable "config" {
  type = object({
    region         = string
    zone           = string
    network_name   = string
    subnet_name    = string
    subnet_cidr    = string
    vm_name        = string
    image_family   = string
    ip_cidr_ranges = list(string)
    allowed_ports  = list(string)
    tags           = list(string)
  })
}

variable "peer_ip" {
  type = string
}

variable "vpn_shared_secret" {
  type = string
}

variable "local_traffic_selector" {
  type = list(string)
}

variable "remote_traffic_selector" {
  type = list(string)
}

variable "project_id" {
  description = "The Google Cloud project ID"
  default     = "terraform-gcp-justjules"
  type        = string
}

variable "american_ip_ranges" {
  type        = list(string)
  description = "List of American IP ranges allowed to access the site"
  default     = ["172.16.0.0/24", "172.16.1.0/24"]
}
