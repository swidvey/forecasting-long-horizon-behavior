variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "secrets" {
  description = "Map of secret ID -> description (description is documentation only)."
  type = map(object({
    description = string
  }))
}

variable "labels" {
  description = "Labels applied to all secrets."
  type        = map(string)
  default     = {}
}
