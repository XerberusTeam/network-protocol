#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH          Set the current working directory (default: $CWD)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        -h|--help) usage ;;  # Display help
    esac
    shift
done

exec $CWD/scripts/up.sh --cwd $CWD --join-testnet