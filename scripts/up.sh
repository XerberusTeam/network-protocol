#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
MODE="join-testnet"

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH          Set the current working directory (default: $CWD)"
    echo "  --mode MODE         Set the mode (default: $MODE), shall be one of: join-testnet, localnet, dev"
    echo "  --dev               Set the mode to dev"
    echo "  --localnet          Set the mode to localnet"
    echo "  --join-testnet      Set the mode to join-testnet (default)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        --mode) MODE="$2"; shift ;;
        --dev) MODE="dev" ;;
        --localnet) MODE="localnet" ;;
        --join-testnet) MODE="join-testnet" ;;
        -h|--help) usage ;;  # Display help
    esac
    shift
done

docker compose -f $CWD/scripts/$MODE.compose.yml down --remove-orphans
docker compose -f $CWD/scripts/$MODE.compose.yml up $@