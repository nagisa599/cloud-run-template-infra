resource "google_artifact_registry_repository" "run-image" {
  project       = var.project_id
  location      = "asia-northeast1"
  repository_id = "gateway"
  description = "Cloud Run services (API)のイメージを格納するArtifact Registryのリポジトリ"
  format        = "DOCKER"
}