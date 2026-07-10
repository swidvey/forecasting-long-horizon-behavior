output "names" {
  description = "Map of bucket suffix -> full bucket name."
  value       = { for id, b in google_storage_bucket.bucket : id => b.name }
}
