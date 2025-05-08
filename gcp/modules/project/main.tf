# プロジェクト情報を取得
data "google_project" "project" {
  project_id = var.project_id  # ここは "manamu-kasyatter-dev" みたいなやつ
}

# project number を出力する
output "project_number" {
  value = data.google_project.project.number
}
