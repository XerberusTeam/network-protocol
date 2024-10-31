# Infra code to manage the xerberus-network-telemetry-web

How to use this project:

- run `./scripts/setup_gcp.sh <your project id> <your email>` to setup the gcp project
- run `make && make prod` to initialize the terraform project and to deploy the infrastructure for the prod
- run `gcloud compute ssh --zone "<your region>" "xerberus-telemetry-web-0" --project "<your project id>"` to ssh into the compute instance
- run `gcloud compute config-ssh` to configure the ssh keys
- then simply run `ssh <your email name>@prod-xerberus-telemetry-web-0.<your region>.<your project id>`
  - eg `ssh foo.bar_myorg_com@prod-xerberus-telemetry-web-0.<your region>.<your project id>`

This provisions a compute instance with the xerberus-network compute vm running on it.
