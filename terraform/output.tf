output "node_app_vm_external_ip" {
  description = "The external IP address of the Node.js app VM"
  value       = google_compute_instance.node_app_vm.network_interface[0].access_config[0].nat_ip
}

output "mongodb_vm_internal_ip" {
  description = "The internal IP address of the MongoDB VM"
  value       = google_compute_instance.mongodb_vm.network_interface[0].network_ip
}

output "mongodb_vm_external_ip" {
  description = "The external IP address of the MongoDB VM"
  value       = google_compute_instance.mongodb_vm.network_interface[0].access_config[0].nat_ip
}
