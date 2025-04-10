# GCP Infrastructure with Terraform

This repository contains Terraform configurations for GCP infrastructure deployment.

## Prerequisites

- Terraform >= 1.5.0
- GCP CLI
- Docker Hub Pro subscription
- Domain name configured

## Setup Instructions

1. Install GCP CLI:

   ```
   curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-latest.tar.gz
   tar -xf google-cloud-cli-latest.tar.gz
   ./google-cloud-sdk/install.sh
   ```

2. Initialize GCP configuration:

   ```
   gcloud init
   ```

3. Initialize Terraform:

   ```
   terraform init
   ```

4. Apply the configuration:
   ```
   terraform plan
   terraform apply
   ```

## Branch Protection Rules

This repository has the following branch protection rules:

- Required pull request reviews
- Required status checks
- No direct pushes to main branch

## Enable following APIs:

1. Compute Engine API
2. DNS API
3. Kubernetes Engine API

## Filters for postgres metrics in GCP PromQL:
```pg_stat_database_tup_returned{namespace="api-server-db"}```
```pg_stat_activity_count{namespace="api-server-db"}```

## Logs for postgres
```
resource.type="k8s_container"
resource.labels.cluster_name="dev-gke-cluster"
resource.labels.namespace_name="api-server-db"
resource.labels.pod_name="api-server-postgres-0"
```
```kubectl exec -it -n api-server-db api-server-postgres-0 -c postgres -- psql -U admin -d api```
SELECT 1; or run any commands
