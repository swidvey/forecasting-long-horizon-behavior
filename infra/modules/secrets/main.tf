# Secret Manager *containers* only. Secret VALUES are added out-of-band via
# gcloud (build plan section 9) so they never touch Terraform state or git:
#
#   echo -n "<value>" | gcloud secrets versions add wikimedia-api-token --data-file=-

resource "google_secret_manager_secret" "secret" {
  for_each = var.secrets

  project   = var.project_id
  secret_id = each.key

  replication {
    auto {}
  }

  labels = var.labels
}
