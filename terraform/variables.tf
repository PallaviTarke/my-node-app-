variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "my-node-vm"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "my-node-app"
}
