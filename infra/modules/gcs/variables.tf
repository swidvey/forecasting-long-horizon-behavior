variable "project_id" {
  description = "GCP project ID (also used as bucket name prefix for global uniqueness)."
  type        = string
}

variable "location" {
  description = "Bucket location (region)."
  type        = string
}

variable "buckets" {
  description = "Map of bucket suffix -> settings. Bucket name becomes <project_id>-<suffix>."
  type = map(object({
    versioning = bool
  }))
}

variable "labels" {
  description = "Labels applied to all buckets."
  type        = map(string)
  default     = {}
}
