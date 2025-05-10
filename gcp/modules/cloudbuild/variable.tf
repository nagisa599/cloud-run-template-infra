variable "project_id" {
  description = "gcp project id"
  type = string
}
variable "project_number" {
    description = "gcp project number"
    type = number
}
variable "github_app_installation_id" {
  description = "GitHub App installation ID"
  type        = string
}
variable "github_oauth_token_secret_version" {
  description = "GitHub OAuth token secret version"
  type        = string
}
variable "github_repository_remote_uri" {
  description = "GitHub repository remote URI"
  type        = string
}