provider "google" {
  project = var.gcp_project
  region  = "us-central1"
}

provider "google-beta" {
  project = var.gcp_project
  region  = "us-central1"
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  owner = var.github_user
  token = var.github_token
}
