terraform {
  required_version = ">= 0.13"
  backend "gcs" {
    bucket = "tfstate-project-pallavi-tarke"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}