output "dataset_ids" {
  description = "Map of dataset ID -> fully qualified dataset ID."
  value       = { for id, ds in google_bigquery_dataset.dataset : id => ds.dataset_id }
}
