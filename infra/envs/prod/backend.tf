# Remote state in GCS. The bucket is the ONE resource created out-of-band
# (chicken-and-egg: Terraform needs somewhere to keep state before it can
# manage anything). Documented one-time creation:
#
#   gcloud storage buckets create gs://forecasting-lhb-prod-tfstate \
#     --location=us-central1 --uniform-bucket-level-access \
#     --public-access-prevention=enforced
#   gcloud storage buckets update gs://forecasting-lhb-prod-tfstate --versioning

terraform {
  backend "gcs" {
    bucket = "forecasting-lhb-prod-tfstate"
    prefix = "envs/prod"
  }
}
