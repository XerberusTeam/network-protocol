resource "google_project_service" "iap" {
  project = local.project_id
  service = "iap.googleapis.com"

  disable_on_destroy = false
}

resource "google_iap_tunnel_instance_iam_binding" "instance_iam" {
  count = local.number_of_instances

  project  = local.project_id
  zone     = local.zone
  instance = google_compute_instance.multiple[count.index].name
  role     = "roles/iap.tunnelResourceAccessor"

  members = formatlist("user:%s", distinct(concat(
    [data.google_client_openid_userinfo.current_user.email],
    local.all_users_iam_binding
  )))

  depends_on = [
    google_project_service.iap,
    google_compute_instance.multiple
  ]
}

# This metadata is already set in the project, so we'll skip managing it via Terraform
# resource "google_compute_project_metadata_item" "os_login" {
#   project = local.project_id
#   key     = "enable-oslogin"
#   value   = "TRUE"
# }

resource "google_project_iam_member" "os_login_users" {
  for_each = toset(formatlist("user:%s", distinct(concat(
    [data.google_client_openid_userinfo.current_user.email],
    local.all_users_iam_binding
  ))))

  project = local.project_id
  role    = "roles/compute.osLogin"
  member  = each.key
}

resource "google_project_iam_member" "iap_tunnel_users" {
  for_each = toset(formatlist("user:%s", distinct(concat(
    [data.google_client_openid_userinfo.current_user.email],
    local.all_users_iam_binding
  ))))

  project = local.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = each.key

  depends_on = [google_project_service.iap]
}

resource "google_project_iam_member" "iap_admins" {
  for_each = toset(formatlist("user:%s", distinct(concat(
    [data.google_client_openid_userinfo.current_user.email],
    local.all_users_iam_binding
  ))))

  project = local.project_id
  role    = "roles/iap.admin"
  member  = each.key

  depends_on = [google_project_service.iap]
}

