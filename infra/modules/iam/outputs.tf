output "emails" {
  description = "Map of service account ID -> email."
  value       = { for id, sa in google_service_account.sa : id => sa.email }
}

output "members" {
  description = "Map of service account ID -> IAM member string (serviceAccount:email)."
  value       = { for id, sa in google_service_account.sa : id => "serviceAccount:${sa.email}" }
}
