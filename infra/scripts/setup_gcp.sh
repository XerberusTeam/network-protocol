#!/bin/bash

# This is a script that adds the roles needed for the user to execute the terraform scripts.
#
# The script takes two arguments:
# 1. PROJECT_ID: The project ID where the roles need to be assigned
# 2. USER_EMAIL: The email address of the user to whom the roles need to be assigned
#
# Example usage:
# ./scripts/setup_gcp.sh project-123456 foobar@xerberus.io

set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 PROJECT_ID USER_EMAIL"
    exit 1
fi

PROJECT_ID="$1"
USER_EMAIL="$2"
CLOUDSDK_COMPUTE_REGION="${CLOUDSDK_COMPUTE_REGION:-europe-west2}"
TF_STATE_BUCKET="${TF_STATE_BUCKET:-tf-state-$PROJECT_ID}"

set_project() {
    gcloud config set project "$PROJECT_ID"
}

enable_api() {
    gcloud services enable "$1" --project="$PROJECT_ID"
}

create_gcs_bucket() {
    gsutil mb -p "$PROJECT_ID" -l "$CLOUDSDK_COMPUTE_REGION" "gs://$1" || true
}

add_iam_policy_binding() {
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="user:$USER_EMAIL" \
        --role="$1"
}

add_iam_policy_binding_gcs_bucket() {
    gsutil iam ch "user:$USER_EMAIL:$1" "gs://$2"
}

# Set project
set_project

# Assign necessary roles
add_iam_policy_binding "roles/compute.admin"
add_iam_policy_binding "roles/iam.serviceAccountAdmin"
add_iam_policy_binding "roles/iam.serviceAccountUser"
add_iam_policy_binding "roles/storage.admin"
add_iam_policy_binding "roles/iap.admin"

# Enable necessary APIs
enable_api "compute.googleapis.com"
enable_api "iam.googleapis.com"
enable_api "iap.googleapis.com"
enable_api "storage-api.googleapis.com"

# Create GCS bucket for Terraform state
create_gcs_bucket "$TF_STATE_BUCKET"

# Grant access to the Terraform state bucket
add_iam_policy_binding_gcs_bucket "roles/storage.objectAdmin" "$TF_STATE_BUCKET"

echo "Setup completed successfully for $USER_EMAIL in project $PROJECT_ID"
