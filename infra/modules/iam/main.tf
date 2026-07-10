# Per-component service accounts (build plan section 9: one SA per component,
# never the default compute SA). IAM grants live in envs/prod/iam.tf so the
# whole policy reads in one place.

resource "google_service_account" "sa" {
  for_each = var.service_accounts

  project      = var.project_id
  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
}
