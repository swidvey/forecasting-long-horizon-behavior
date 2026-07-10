# Forecasting platform -- prod environment.
# Phase 0 scope: identities, data containers, secret containers.
# Later phases add: WIF (CI auth), Cloud Run + Scheduler (ingestion),
# Vertex/monitoring/budget modules.

module "iam" {
  source     = "../../modules/iam"
  project_id = var.project_id

  service_accounts = {
    ingest-sa = {
      display_name = "Ingestion (Cloud Run)"
      description  = "Pulls Wikimedia pageviews; writes GCS raw and BQ raw/staging."
    }
    pipeline-sa = {
      display_name = "Vertex AI Pipelines"
      description  = "Training/inference: reads main, writes forecasts, metrics, champions."
    }
    eval-sa = {
      display_name = "Evaluation job"
      description  = "Scores past forecasts against arriving actuals."
    }
    terraform-sa = {
      display_name = "Terraform (CI)"
      description  = "Infrastructure management via WIF from GitHub Actions. Grants added with WIF setup."
    }
  }
}

module "bq" {
  source     = "../../modules/bq"
  project_id = var.project_id
  location   = var.region
  labels     = var.labels

  datasets = {
    raw = {
      description = "Landing zone: API responses as loaded from GCS. Immutable."
    }
    staging = {
      description = "Typed, deduplicated, one row per (article, date). DQ checks run here."
    }
    main = {
      description = "Curated warehouse: fact_pageviews, dims, forecasts ledger, scores, champions."
    }
  }
}

module "gcs" {
  source     = "../../modules/gcs"
  project_id = var.project_id
  location   = var.region
  labels     = var.labels

  buckets = {
    raw = {
      versioning = false # landing zone; BQ raw layer is the durable copy
    }
    artifacts = {
      versioning = true # pipeline artifacts, model binaries
    }
  }
}

module "secrets" {
  source     = "../../modules/secrets"
  project_id = var.project_id
  labels     = var.labels

  secrets = {
    wikimedia-api-token = {
      description = "Optional OAuth token for higher Wikimedia API rate limits (backfill)."
    }
    alert-webhook-url = {
      description = "Webhook for alert routing beyond email, if used."
    }
  }
}
