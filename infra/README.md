# Infrastructure (Terraform)

Everything in GCP is managed here, except the Terraform state bucket itself
(chicken-and-egg; created once, out-of-band):

```
gcloud storage buckets create gs://forecasting-lhb-prod-tfstate --location=us-central1 --uniform-bucket-level-access --public-access-prevention=enforced
gcloud storage buckets update gs://forecasting-lhb-prod-tfstate --versioning
```

## Layout

- `modules/` — reusable building blocks (iam, bq, gcs, secrets; more added per phase)
- `envs/prod/` — the single environment. `iam.tf` is the complete access policy in one file.

## Usage (local, as a human)

Authenticate once with ADC (`gcloud auth application-default login`), then:

```
cd infra/envs/prod
terraform init
terraform plan
terraform apply
```

No service account keys are used anywhere: humans run as themselves via ADC;
CI will run via Workload Identity Federation (added with the deploy workflow).

## Known deviation

The build plan calls for the org policy `iam.disableServiceAccountKeyCreation`.
This account has no GCP Organization (personal account), and org policies
require one — so key creation cannot be *technically* prevented. Mitigation:
no code path uses keys, IAM grants are least-privilege, and any `*.json`
credential file is gitignored defensively.

## Secret values

Terraform manages secret *containers* only. Values are added out-of-band:

```
echo -n "<value>" | gcloud secrets versions add wikimedia-api-token --data-file=-
```
