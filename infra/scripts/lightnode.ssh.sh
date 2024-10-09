#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
DRY_RUN=""
MORE_ARGS=""

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH            Set the current working directory (default: $CWD)"
    echo "  --dry-run             Print the command that would be run, but do not run it."
    echo "  -h, --help            Display help"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        --dry-run) DRY_RUN="--dry-run" ;;
        -h|--help) usage ;;  # Display help
        *) MORE_ARGS="$MORE_ARGS $1" ;;
    esac
    shift
done

CMD_STR=$(terraform -chdir=$CWD/terraform/ output iap_lightnode_tunnel_command)
eval CMD=$CMD_STR
exec $CMD $DRY_RUN $COMMAND -- $MORE_ARGS