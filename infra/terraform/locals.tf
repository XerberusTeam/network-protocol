locals {
  env_file     = "./environments/${terraform.workspace}.yaml"
  env_name     = terraform.workspace == "default" ? "testnet" : terraform.workspace
  env_contents = fileexists(local.env_file) ? file(local.env_file) : file("./environments/testnet.yaml")
  settings     = yamldecode(local.env_contents)
  project_id   = local.settings.project_id
  region       = local.settings.region
  zone         = local.settings.zone
  prefix       = "${local.env_name}-xerberus"
  machine_type = "e2-standard-8"
  compute_name = "${local.prefix}-compute"

  number_of_instances = 1

  # Environment variables for the function
  env_vars = {
    ENVIRONMENT = local.env_name
    PROJECT_ID  = local.project_id
  }

  # Service account configuration
  service_account_id   = "${lower(replace(local.compute_name, "/\\W|_|\\s/", "-"))}-sa"
  service_account_name = "${local.compute_name} service account"

  all_users_iam_binding = distinct(concat(
    local.settings.all_users_iam_binding,
    [
      # placeholder to add any perm users
      # example: "foo.bar@myorg.com"
    ]
  ))

  # Tags
  common_tags = {
    environment = local.env_name
    project     = "xerberus-network"
    managed_by  = "terraform"
  }
}