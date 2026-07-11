output "provider_name" {
  description = "Full provider resource name -- the value for google-github-actions/auth's workload_identity_provider input."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "pool_name" {
  description = "Full pool resource name."
  value       = google_iam_workload_identity_pool.github.name
}
