# -----------------------------------------
# cloud-buildを実行するためのサービスアカウント
# -----------------------------------------
resource "google_service_account" "cloudbuild_service_account" {
  account_id   = "cloudbuild-sa"
  display_name = "cloudbuild-sa"
  description  = "Cloud build service account"
}
resource "google_project_iam_member" "act_as" {
  for_each = toset([
    "roles/run.developer",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/artifactregistry.writer"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

# -----------------------------------------
# Cloud Build が GitHub 連携時に Secret Manager のトークンを読むために、内部的に使う「マネージドサービスアカウント」
# -----------------------------------------
resource "google_project_iam_member" "cloudbuild_managed_sa_secret_access" {
  for_each = toset([
    "roles/secretmanager.secretAccessor",
  ])
  role    =each.key
  member  = "serviceAccount:service-${var.project_number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
  project = var.project_id
}

# -----------------------------------------
# githubのトークンをSecret Managerに格納
# -----------------------------------------
resource "google_secret_manager_secret" "github_token" {
  secret_id  = "github-token"
  replication {
    user_managed {
      replicas {
        location = "asia-northeast1"
      }
    }
  }
}

# ------------------------------------------
# githubのトークンを実際に格納
# ------------------------------------------
resource "google_secret_manager_secret_version" "github_token_version" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.github_oauth_token_secret_version
}
# ------------------------------------------
# githubのトークンをSecret Managerから取得
# ------------------------------------------
data "google_secret_manager_secret_version" "github_token_secret_version" {
  secret  = google_secret_manager_secret.github_token.secret_id
  project = var.project_id
}

# ------------------------------------------
# githubとの連携を行うための接続情報
# ------------------------------------------
resource "google_cloudbuildv2_connection" "github_connection" {
  location = "us-central1"
  name = "github-connection"

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = data.google_secret_manager_secret_version.github_token_secret_version.name
    }
  }
}

# ------------------------------------------
# githubのリポジトリ情報
# ------------------------------------------
resource "google_cloudbuildv2_repository" "github_repository" {
  name = "github-repository"
  parent_connection = google_cloudbuildv2_connection.github_connection.id
  remote_uri = var.github_repository_remote_uri
}

# ------------------------------------------
# Cloud Buildのトリガーを作成
# ------------------------------------------
resource "google_cloudbuild_trigger" "my-app_trigger" {
  location = "us-central1"
  project = var.project_id
  service_account = google_service_account.cloudbuild_service_account.id
  repository_event_config {
    repository = google_cloudbuildv2_repository.github_repository.id
    push {
      branch = "^main$"
    }
  }
  filename = "my-app/cloudbuild.yaml"
  substitutions = {
    _REGION                         = "asia-northeast1"
    _ARTIFACT_REPOSITORY_IMAGE_NAME = "asia-northeast1-docker.pkg.dev/${var.project_id}/gateway/test_2"
  }

}