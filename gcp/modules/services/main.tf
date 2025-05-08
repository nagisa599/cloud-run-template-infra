
resource "google_project_service" "activate_gcp_services" {
  for_each = toset(var.gcp_service_list)
  service  = each.key
  project  = var.project_id
}

