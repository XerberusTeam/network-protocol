#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
MODE="full-node"

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH          Set the current working directory (default: $CWD)"
    echo "  --mode MODE         Set the mode (default: $MODE), shall be one of: full-node, localnet, dev"
    echo "  --dev               Set the mode to dev"
    echo "  --localnet          Set the mode to localnet"
    echo "  --full-node         Set the mode to full-node (default)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        --mode) MODE="$2"; shift ;;
        --dev) MODE="dev" ;;
        --localnet) MODE="localnet" ;;
        --full-node) MODE="full-node" ;;
        -h|--help) usage ;;  # Display help
    esac
    shift
done

docker compose -f $CWD/scripts/$MODE.compose.yml down --remove-orphans
