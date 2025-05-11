# --------------------------------------
# Cloud Runのサービスを作成するためのモジュール
# --------------------------------------
resource "google_cloud_run_service" "configure_cloud_run_service" {
  name                       = "sample-api-cloud-run" # Cloud Runのサービス名
  location                   = "asia-northeast1" # Cloud Runのリージョン
  autogenerate_revision_name = true # 自動でリビジョン末尾の識別文字列を入れるために必要
  

  template {
    spec {
      # Cloud Runのサービスのコンテナイメージを指定
      timeout_seconds       = 300
      container_concurrency = 50
      containers {
        image = "asia-northeast1-docker.pkg.dev/${var.project_id}/gateway/test_2:latest"
        resources {
          limits = {
            "memory" : "256Mi",
            "cpu" : "1"
          }
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0" # autoscalingの最小値
        "autoscaling.knative.dev/maxScale" = "1" # autoscalingの最大値
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      # gcloudからデプロイしたとき、以下のパラメータが入る。変更差分として判定したくないのでチェック対象から外す
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
      # Clour Buildからビルド・デプロイしたとき、以下のパラメータが入る。変更差分として判定したくないのでチェック対象から外す
      template[0].metadata[0].labels,
      template[0].spec[0].containers["image"]
    ]
  }
}
# --------------------------------------
# Cloud Runにアクセスできるユーザの制限
# --------------------------------------
resource "google_cloud_run_service_iam_member" "user_access" {
  location = google_cloud_run_service.configure_cloud_run_service.location
  project  = var.project_id
  service  = google_cloud_run_service.configure_cloud_run_service.name

  role   = "roles/run.invoker"
  member = "user:nagisa_nasu@manamu.jp"
}

