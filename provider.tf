terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.20.0"
    }
  }
}

provider "google" {
  project = "mentoring-batch-1"
  region =  "europe-north1"
  credentials = "./credentials.json"
}