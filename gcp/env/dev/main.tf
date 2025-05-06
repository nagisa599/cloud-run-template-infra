terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.40.0"
    }
  }
  required_version = ">= 1.3"
#   backend "gcs" {}
}


provider "google" {
  project                     = var.project_id
  region                      = "asia-northeast1"
#   impersonate_service_account = "nagisa-nasu@${var.project_name}.iam.gserviceaccount.com"
}

module "service" {
  source = "../../modules/services"
}

# module "cloudbuild" {
#   source     = "../../modules/cloudbuild"
#   depends_on = [module.service]
#   project_id = var.project_id
# }

module "cloudrun" {
  source       = "../../modules/cloudrun"
  depends_on   = [module.service]
  project_id   = var.project_id
  project_name = var.project_name
}
module "gar" {
  source       = "../../modules/gar"
  depends_on   = [module.service]
  project_id = var.project_id
}