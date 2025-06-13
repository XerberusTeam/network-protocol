#!/usr/bin/env bash

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
# IMP Note: Directly testnet bucket's been configured
TF_STATE_BUCKET="${TF_STATE_BUCKET:-testnet-v2-xerberus-tf-state}"

set_project() {
    gcloud config set project "$PROJECT_ID"
    if [ $? -ne 0 ]; then
        echo "Failed to set project $PROJECT_ID"
        exit 1
    else
        echo "Successfully set project $PROJECT_ID"
    fi
}

enable_api() {
    local api=$1
    gcloud services enable "$api" --project="$PROJECT_ID"
    if [ $? -ne 0 ]; then
        echo "Failed to enable API $api for project $PROJECT_ID"
        exit 1
    else
        echo "Successfully enabled API $api for project $PROJECT_ID"
    fi
}

create_gcs_bucket() {
    local bucket_name=$1
    gsutil mb -p "$PROJECT_ID" -l "$CLOUDSDK_COMPUTE_REGION" "gs://$bucket_name" || true
}

add_iam_policy_binding() {
    local role=$1
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="user:$USER_EMAIL" \
        --role="$role" \
        --condition=None
}

add_iam_policy_binding_gcs_bucket() {
    local role=$1
    local bucket_name=$2
    gsutil iam ch "user:$USER_EMAIL:$role" "gs://$bucket_name"
}

# Set project
set_project

# Assign necessary roles
add_iam_policy_binding "roles/compute.admin"
add_iam_policy_binding "roles/compute.loadBalancerAdmin"
add_iam_policy_binding "roles/iam.serviceAccountAdmin"
add_iam_policy_binding "roles/iam.serviceAccountUser"
add_iam_policy_binding "roles/storage.admin"
add_iam_policy_binding "roles/iap.admin"
add_iam_policy_binding "roles/networkmanagement.admin"

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
