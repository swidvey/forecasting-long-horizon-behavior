output "service_account_emails" {
  description = "Per-component service account emails."
  value       = module.iam.emails
}

output "datasets" {
  description = "BigQuery datasets."
  value       = module.bq.dataset_ids
}

output "buckets" {
  description = "GCS buckets."
  value       = module.gcs.names
}

output "secrets" {
  description = "Secret Manager containers (values added out-of-band)."
  value       = module.secrets.secret_ids
}
