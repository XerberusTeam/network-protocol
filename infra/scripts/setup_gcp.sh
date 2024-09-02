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
CLOUDSDK_COMPUTE_REGION="${CLOUDSDK_COMPUTE_REGION:-EUROPE-WEST2}"
TF_STATE_BUCKET="${TF_STATE_BUCKET:-terraform-state-$PROJECT_ID}"

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

# Create GCS bucket if it doesn't exist
create_gcs_bucket() {
  local bucket_name=$1
  if ! gsutil ls -p "$PROJECT_ID" | grep -q "gs://$bucket_name/"; then
    gsutil mb -p "$PROJECT_ID" -l "$CLOUDSDK_COMPUTE_REGION" "gs://$bucket_name"
    if [ $? -ne 0 ]; then
      echo "Failed to create GCS bucket $bucket_name"
      exit 1
    else
      echo "Successfully created GCS bucket $bucket_name"
    fi
  else
    echo "GCS bucket $bucket_name already exists"
  fi
}

# Add IAM policy binding to a specific GCS bucket
add_iam_policy_binding_gcs_bucket() {
  local role=$1
  local bucket_name=$2
  gsutil iam ch "user:$USER_EMAIL:$role" "gs://$bucket_name"
  if [ $? -ne 0 ]; then
    echo "Failed to add role $role to $USER_EMAIL on GCS bucket $bucket_name"
    exit 1
  else
    echo "Successfully added role $role to $USER_EMAIL on GCS bucket $bucket_name"
  fi
}

# Add IAM policy binding
add_iam_policy_binding() {
  local role=$1
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
      --member="user:$USER_EMAIL" \
      --role="$role"
  if [ $? -ne 0 ]; then
    echo "Failed to add role $role to $USER_EMAIL"
    exit 1
  else
    echo "Successfully added role $role to $USER_EMAIL"
  fi
}

# Set project
set_project "$PROJECT_ID"

# Assign roles
add_iam_policy_binding "roles/serviceusage.serviceUsageAdmin"
add_iam_policy_binding "roles/iam.serviceAccountAdmin"
add_iam_policy_binding "roles/storage.admin"
add_iam_policy_binding "roles/artifactregistry.admin"
add_iam_policy_binding "roles/monitoring.viewer"
add_iam_policy_binding "roles/secretmanager.admin"
add_iam_policy_binding "roles/bigquery.admin"
add_iam_policy_binding "roles/bigquery.jobUser"
add_iam_policy_binding "roles/compute.networkAdmin"
add_iam_policy_binding "roles/compute.admin"
add_iam_policy_binding "roles/compute.instanceAdmin"
add_iam_policy_binding "roles/compute.instanceAdmin.v1"
add_iam_policy_binding "roles/iam.serviceAccountUser"

# Enable necessary APIs
enable_api "bigquery.googleapis.com"
enable_api "storage.googleapis.com"

# Create GCS bucket for Terraform state
create_gcs_bucket "$TF_STATE_BUCKET"

add_iam_policy_binding_gcs_bucket "roles/storage.objectAdmin" "$TF_STATE_BUCKET"

echo "IAM roles assigned successfully to $USER_EMAIL in project $PROJECT_ID"
