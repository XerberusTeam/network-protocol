#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"

CMD_STR=$(terraform -chdir=$CWD/terraform/ output iap_tunnel_command)
eval CMD=$CMD_STR
exec $CMD