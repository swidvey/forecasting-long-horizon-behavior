# BigQuery datasets: raw -> staging -> main warehouse layers (build plan
# section 2). Tables are created by ETL/DDL, not Terraform -- Terraform owns
# the containers and their access boundaries.

resource "google_bigquery_dataset" "dataset" {
  for_each = var.datasets

  project     = var.project_id
  dataset_id  = each.key
  description = each.value.description
  location    = var.location

  # Never let a terraform destroy take the data with it silently.
  delete_contents_on_destroy = false

  labels = var.labels
}
