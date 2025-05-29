variable "credentials_path" {
  description = "Path to the Google Cloud credentials file"
  type        = string
  default     = null
}

provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = (var.credentials_path != null && var.credentials_path != "null") ? file(var.credentials_path) : null
}

# Node.js App VM
resource "google_compute_instance" "node_app_vm" {
  name         = var.vm_name
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Install Docker
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Pull and run the Node.js app container
    docker pull gcr.io/${var.project_id}/${var.service_name}:latest
    docker run -d --name node-app -p 8080:8080 -e MONGO_URI="mongodb://${google_compute_instance.mongodb_vm.network_interface[0].network_ip}:27017" gcr.io/${var.project_id}/${var.service_name}:latest
  EOF

  tags = ["http-server", "app-vm"]
}

# MongoDB VM
resource "google_compute_instance" "mongodb_vm" {
  name         = var.mongodb_vm_name
  machine_type = "e2-medium"
  zone         = "${var.region}-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Install Docker
    apt-get update
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker

    # Pull and run the MongoDB container
    docker run -d --name mongodb -p 27017:27017 mongo:latest
  EOF

  tags = ["mongodb-vm"]
}

# Firewall rule to allow HTTP traffic to the Node.js app
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

# Firewall rule to allow Node.js app VM to access MongoDB VM on port 27017
resource "google_compute_firewall" "allow_mongodb" {
  name    = "allow-mongodb"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_tags = ["app-vm"]
  target_tags = ["mongodb-vm"]
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "containerregistry" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
  disable_on_destroy = false
}
