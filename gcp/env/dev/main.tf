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
  project = var.project_id
  region  = "asia-northeast1"
  #   impersonate_service_account = "nagisa-nasu@${var.project_name}.iam.gserviceaccount.com"
}
module "project" {
  source     = "../../modules/project"
  project_id = var.project_id
}

module "service" {
  source       = "../../modules/services"
  project_id   = var.project_id
  project_name = var.project_name
}

module "cloudbuild" {
  source                            = "../../modules/cloudbuild"
  depends_on                        = [module.service]
  project_id                        = var.project_id
  project_number                    = module.project.project_number
  github_app_installation_id        = var.github_app_installation_id
  github_oauth_token_secret_version = var.github_oauth_token_secret_version
  github_repository_remote_uri      = var.github_repository_remote_uri
}

# ------------------------------------------
# Cloud Runのサービスを作成するためのモジュール
# 最初に実行するときは、コメントアウトして、GCRのイメージを作成してから、コメントアウトを外して実行する
# ------------------------------------------
module "cloudrun" {
  source       = "../../modules/cloudrun"
  depends_on   = [module.service]
  project_id   = var.project_id
  project_name = var.project_name
}
module "gar" {
  source     = "../../modules/gar"
  depends_on = [module.service]
  project_id = var.project_id
}