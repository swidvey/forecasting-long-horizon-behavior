# Workload Identity Federation for GitHub Actions (build plan section 9).
#
# Trust chain: GitHub signs an OIDC token per workflow run -> this pool
# accepts it ONLY if assertion.repository matches our repo -> the token
# holder may impersonate terraform-sa for the duration of the run.
# No stored credentials anywhere.

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions"
  description               = "Federated identities for GitHub Actions workflow runs."
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Hard gate: tokens from any other repository are rejected at the door.
  attribute_condition = "assertion.repository == \"${var.github_repository}\""
}

# Allow workflow runs from our repository to impersonate the deploy SA.
resource "google_service_account_iam_member" "github_impersonation" {
  service_account_id = "projects/${var.project_id}/serviceAccounts/${var.service_account_email}"
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}
