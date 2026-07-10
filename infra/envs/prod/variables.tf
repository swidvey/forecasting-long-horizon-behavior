variable "project_id" {
  description = "GCP project ID."
  type        = string
  default     = "forecasting-lhb-prod"
}

variable "region" {
  description = "Single region for everything (build plan: us-central1)."
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Common labels for all resources."
  type        = map(string)
  default = {
    managed-by = "terraform"
    app        = "forecasting-lhb"
  }
}
