variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "github_repository" {
  description = "GitHub repo (owner/name) whose workflow runs may authenticate."
  type        = string
}

variable "service_account_email" {
  description = "Service account that federated workflow runs may impersonate."
  type        = string
}

variable "pool_id" {
  description = "Workload identity pool ID. NOTE: pool IDs are soft-deleted for 30 days and cannot be reused during that window."
  type        = string
  default     = "github"
}

variable "provider_id" {
  description = "Workload identity pool provider ID."
  type        = string
  default     = "github-oidc"
}
