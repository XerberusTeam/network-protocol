#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
MODE="dev"

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH          Set the current working directory (default: $CWD)"
    echo "  --mode MODE         Set the mode (default: $MODE), shall be one of: dev"
    echo "  --dev               Set the mode to dev  (default)"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        --mode) MODE="$2"; shift ;;
        --dev) MODE="dev" ;;
        -h|--help) usage ;;
    esac
    shift
done

docker compose -f $CWD/scripts/$MODE.compose.yml down --remove-orphans
docker compose -f $CWD/scripts/$MODE.compose.yml up $@
