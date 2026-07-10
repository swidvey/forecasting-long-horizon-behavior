# GCS buckets. Security defaults are non-negotiable (build plan section 9):
# uniform bucket-level access + public access prevention on everything.

resource "google_storage_bucket" "bucket" {
  for_each = var.buckets

  project  = var.project_id
  name     = "${var.project_id}-${each.key}"
  location = var.location

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # Refuse to destroy a non-empty bucket.
  force_destroy = false

  versioning {
    enabled = each.value.versioning
  }

  labels = var.labels
}
