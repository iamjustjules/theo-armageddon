output "european_vpc_id" {
  value = google_compute_network.european_vpc.id
  description = "VPC ID for the European Headquarters"
}

output "american_vpc1_id" {
  value = google_compute_network.american_vpc1.id
  description = "VPC ID for the first American office"
}

output "american_vpc2_id" {
  value = google_compute_network.american_vpc2.id
  description = "VPC ID for the second American office"
}

output "asia_pacific_vpc_id" {
  value = google_compute_network.asia_pacific_vpc.id
  description = "VPC ID for the Asia Pacific office"
}

output "european_subnet_range" {
  value = google_compute_subnetwork.european_subnet.ip_cidr_range
  description = "IP CIDR range for the European subnet"
}

output "american_subnet1_range" {
  value = google_compute_subnetwork.american_subnet1.ip_cidr_range
  description = "IP CIDR range for the first American subnet"
}

output "american_subnet2_range" {
  value = google_compute_subnetwork.american_subnet2.ip_cidr_range
  description = "IP CIDR range for the second American subnet"
}

output "asia_pacific_subnet_range" {
  value = google_compute_subnetwork.asia_pacific_subnet.ip_cidr_range
  description = "IP CIDR range for the Asia Pacific subnet"
}
output "secret_value" {
  value       = data.google_secret_manager_secret_version.my_secret.secret_data
  description = "The value of the fetched secret."
  sensitive   = true  
}