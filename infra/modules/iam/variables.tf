variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "service_accounts" {
  description = "Map of service account ID -> display name and description."
  type = map(object({
    display_name = string
    description  = string
  }))
}
