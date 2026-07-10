output "secret_ids" {
  description = "Map of secret ID -> full resource ID."
  value       = { for id, s in google_secret_manager_secret.secret : id => s.id }
}
