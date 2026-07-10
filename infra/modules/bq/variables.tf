variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "location" {
  description = "BigQuery dataset location (region)."
  type        = string
}

variable "datasets" {
  description = "Map of dataset ID -> description."
  type = map(object({
    description = string
  }))
}

variable "labels" {
  description = "Labels applied to all datasets."
  type        = map(string)
  default     = {}
}
