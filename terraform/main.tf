provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_registry_api" {
  service = "containerregistry.googleapis.com"
  disable_on_destroy = false
}

# Cloud Run service
resource "google_cloud_run_service" "node_app" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.service_name}:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.run_api,
    google_project_service.container_registry_api
  ]
}

# Allow unauthenticated access (optional, remove for private service)
resource "google_cloud_run_service_iam_member" "public_access" {
  service  = google_cloud_run_service.node_app.name
  location = google_cloud_run_service.node_app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}