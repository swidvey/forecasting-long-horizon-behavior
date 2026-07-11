# IAM policy for the platform, in one file so it reads like documentation
# (build plan section 9). Rules:
#   - grants at the narrowest resource level (per-dataset, per-bucket, per-secret)
#   - project-level roles only where GCP requires it (bigquery.jobUser to run jobs)
#   - google_*_iam_member (additive) everywhere -- never authoritative bindings
#     that could wipe grants made outside this file.
#
# terraform-sa gets NO grants yet: its roles arrive with WIF setup (next
# session) so CI-deploy permissions are reviewed as one changeset.

# -------------------------------------------------------------- terraform-sa
# Deploy identity for CI (impersonated via WIF -- see modules/wif). These
# roles let it manage exactly what this configuration manages, and nothing
# it doesn't. Honest caveat: projectIamAdmin can grant roles, which is
# inherently powerful; acceptable for a single-owner project, and every
# grant it makes lands in reviewed Terraform anyway. A locked-down custom
# role is the enterprise refinement.

resource "google_project_iam_member" "terraform_sa_roles" {
  for_each = toset([
    "roles/bigquery.admin",                # datasets + dataset IAM
    "roles/storage.admin",                 # buckets + bucket IAM (incl. tfstate)
    "roles/secretmanager.admin",           # secret containers + secret IAM
    "roles/iam.serviceAccountAdmin",       # manage the component SAs
    "roles/iam.workloadIdentityPoolAdmin", # manage the WIF pool itself
    "roles/resourcemanager.projectIamAdmin", # project-level IAM grants in this file
    "roles/serviceusage.serviceUsageConsumer", # call enabled APIs
  ])

  project = var.project_id
  role    = each.value
  member  = module.iam.members["terraform-sa"]
}

# Human impersonation of terraform-sa is intentionally NOT bound here: the
# project owner already applies with their own ADC, and adding the binding
# would publish a personal email in a public repo. Revisit if a second
# human ever needs deploy rights.

# ---------------------------------------------------------------- ingest-sa
# Writes raw files to GCS, loads BQ raw, transforms into staging.

resource "google_storage_bucket_iam_member" "ingest_raw_bucket" {
  bucket = module.gcs.names["raw"]
  role   = "roles/storage.objectAdmin" # create + overwrite on re-runs
  member = module.iam.members["ingest-sa"]
}

resource "google_bigquery_dataset_iam_member" "ingest_raw_dataset" {
  project    = var.project_id
  dataset_id = module.bq.dataset_ids["raw"]
  role       = "roles/bigquery.dataEditor"
  member     = module.iam.members["ingest-sa"]
}

resource "google_bigquery_dataset_iam_member" "ingest_staging_dataset" {
  project    = var.project_id
  dataset_id = module.bq.dataset_ids["staging"]
  role       = "roles/bigquery.dataEditor"
  member     = module.iam.members["ingest-sa"]
}

resource "google_project_iam_member" "ingest_bq_jobs" {
  project = var.project_id
  role    = "roles/bigquery.jobUser" # required at project level to run load/query jobs
  member  = module.iam.members["ingest-sa"]
}

resource "google_secret_manager_secret_iam_member" "ingest_wikimedia_token" {
  project   = var.project_id
  secret_id = module.secrets.secret_ids["wikimedia-api-token"]
  role      = "roles/secretmanager.secretAccessor"
  member    = module.iam.members["ingest-sa"]
}

# --------------------------------------------------------------- pipeline-sa
# Reads main, writes forecasts/backtest_metrics/champions (all tables live in
# the main dataset -> dataset-level dataEditor for now; tighten to table-level
# IAM once the tables exist in Phase 2).

resource "google_bigquery_dataset_iam_member" "pipeline_main_dataset" {
  project    = var.project_id
  dataset_id = module.bq.dataset_ids["main"]
  role       = "roles/bigquery.dataEditor"
  member     = module.iam.members["pipeline-sa"]
}

resource "google_project_iam_member" "pipeline_bq_jobs" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = module.iam.members["pipeline-sa"]
}

resource "google_storage_bucket_iam_member" "pipeline_artifacts_bucket" {
  bucket = module.gcs.names["artifacts"]
  role   = "roles/storage.objectAdmin"
  member = module.iam.members["pipeline-sa"]
}

resource "google_project_iam_member" "pipeline_vertex" {
  project = var.project_id
  role    = "roles/aiplatform.user" # run Vertex pipelines/jobs
  member  = module.iam.members["pipeline-sa"]
}

# ------------------------------------------------------------------- eval-sa
# Reads forecasts + main, writes actuals_scores (same dataset -> dataEditor;
# same table-level tightening TODO as pipeline-sa).

resource "google_bigquery_dataset_iam_member" "eval_main_dataset" {
  project    = var.project_id
  dataset_id = module.bq.dataset_ids["main"]
  role       = "roles/bigquery.dataEditor"
  member     = module.iam.members["eval-sa"]
}

resource "google_project_iam_member" "eval_bq_jobs" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = module.iam.members["eval-sa"]
}
