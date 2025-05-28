provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_registry_api" {
  service = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

# Create a Compute Engine VM
resource "google_compute_instance" "node_app_vm" {
  name         = var.vm_name
  machine_type = "e2-micro" # Free-tier eligible
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable" # Container-Optimized OS
    }
  }

  network_interface {
    network = "default"
    access_config {} # Assigns external IP
  }

  metadata = {
    "gce-container-declaration" = <<-EOT
    spec:
      containers:
      - name: ${var.service_name}
        image: gcr.io/${var.project_id}/${var.service_name}:latest
        env:
        - name: PORT
          value: "8080"
      restartPolicy: Always
    EOT
  }

  service_account {
    email  = "428456782983-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  tags = ["http-server"]

  depends_on = [
    google_project_service.compute_api,
    google_project_service.container_registry_api
  ]
}

# Firewall rule to allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
