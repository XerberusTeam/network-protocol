# Infra code to manage the xerberus-network-compute

How to use this project:

- run `./scripts/setup_gcp.sh <your project id> <your email>` to setup the gcp project
- run `make && make testnet` to initialize the terraform project and to deploy the infrastructure for the testnet
- run `gcloud compute ssh --zone "<your region>" "testnet-xerberus-compute-0" --project "<your project id>"` to ssh into the compute instance
- run `gcloud compute config-ssh` to configure the ssh keys
- then simply run `ssh <your email name>@testnet-xerberus-compute-0.<your region>.<your project id>`
  - eg `ssh foo.bar_myorg_com@testnet-xerberus-compute-0.<your region>.<your project id>`

This provisions a compute instance with the xerberus-network compute vm running on it.
