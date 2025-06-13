#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"

# Clean ansible directory on VM and copy it
$CWD/scripts/lightnode.ssh.sh rm -rf ./ansible

# Use -raw flag to avoid issues with quotes
terraform -chdir=$CWD/terraform/ output -raw iap_lightnode_scp_command | bash

# Clean scripts directory on VM and copy it
$CWD/scripts/lightnode.ssh.sh rm -rf ./scripts

# Use -raw flag to avoid issues with quotes
terraform -chdir=$CWD/terraform/ output -raw lightnode_scripts_scp_command | bash