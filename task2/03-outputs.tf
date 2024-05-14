output "public_ip" {
  value       = google_compute_instance.just_jules_vm.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the VM."
}

output "vpc_name" {
  value       = google_compute_network.just_jules_vpc.name
  description = "The name of the VPC."
}

output "subnet_name" {
  value       = google_compute_subnetwork.just_jules_subnet.name
  description = "The name of the subnet."
}

output "internal_ip" {
  value       = google_compute_instance.just_jules_vm.network_interface[0].network_ip
  description = "The internal IP address of the VM."
}

output "website_url" {
  value       = "http://${google_storage_bucket.my_bucket.name}.storage.googleapis.com/index.html"
  description = "URL of the static website hosted on GCS."
}

output "secret_value" {
  value       = data.google_secret_manager_secret_version.my_secret.secret_data
  description = "The value of the fetched secret."
  sensitive   = true  
}

