#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"

$CWD/scripts/ssh.sh rm -rf ./ansible

CMD_STR=$(terraform -chdir=$CWD/terraform/ output iap_scp_command)
eval CMD=$CMD_STR
exec $CMD