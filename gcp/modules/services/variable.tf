variable "project_name" {
  description = "gcp project name"
  type        = string
}
variable "project_id" {
  description = "gcp project id"
  type        = string
}
variable "gcp_service_list" {
  type = list(string)
  default = [
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "run.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}
