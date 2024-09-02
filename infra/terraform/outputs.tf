output "project_id" {
  description = "The ID of the GCP project"
  value       = local.project_id
}

output "region" {
  description = "The region where resources are deployed"
  value       = local.region
}

output "zone" {
  description = "The zone where compute instances are deployed"
  value       = local.zone
}

output "compute_names" {
  description = "Names of the node instances"
  value       = google_compute_instance.multiple[*].name
}

output "polkadot_node_internal_ips" {
  description = "Internal IP addresses of the node instances"
  value       = google_compute_instance.multiple[*].network_interface[0].network_ip
}

output "service_account_email" {
  description = "Email of the service account used by the node instances"
  value       = google_service_account.this.email
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.this.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.this.name
}

output "iap_tunnel_command" {
  description = "Command to SSH into the instance using IAP tunneling"
  value       = "gcloud compute ssh --zone ${local.zone} ${google_compute_instance.multiple[0].name} --tunnel-through-iap --project ${local.project_id}"
}

output "os_login_enabled" {
  description = "Indicates whether OS Login is enabled"
  value       = google_compute_project_metadata_item.os_login.value
}

output "firewall_rule_name" {
  description = "Name of the firewall rule allowing IAP SSH access"
  value       = google_compute_firewall.allow_iap_ssh.name
}

output "polkadot_node_public_ips" {
  description = "Public IP addresses of the Polkadot node instances"
  value       = google_compute_address.static_ip[*].address
}