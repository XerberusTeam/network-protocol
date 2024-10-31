terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.35.0"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
}

terraform {
  backend "gcs" {
    bucket = "${local.prefix}-tf-state"
    prefix = "terraform/state/xerberus-network-telemetry-web"
  }
}

data "google_project" "project" {}

data "google_client_openid_userinfo" "current_user" {}

resource "google_service_account" "this" {
  account_id   = local.service_account_id
  display_name = local.service_account_name
}

resource "google_service_account_key" "this" {
  service_account_id = google_service_account.this.name
}

resource "google_service_account_iam_binding" "this" {
  service_account_id = "projects/${local.project_id}/serviceAccounts/${google_service_account.this.email}"
  role               = "roles/iam.serviceAccountUser"

  members = formatlist("user:%s", distinct(concat(
    [data.google_client_openid_userinfo.current_user.email],
    local.all_users_iam_binding
  )))
}

resource "google_project_iam_member" "this" {
  project = local.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.this.email}"
}
