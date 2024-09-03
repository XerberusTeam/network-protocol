#!/bin/bash -ex

export ANSIBLE_HOST_KEY_CHECKING=False

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
INVENTORY="testnet"

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH    Set the current working directory (default: $CWD)"
    echo "  --inventory   Set the inventory file (default: $INVENTORY)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        --inventory) INVENTORY="$2"; shift ;;
        -h|--help) usage ;;  # Display help
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

ansible-playbook $CWD/main.yml -i $CWD/group_vars/inventory/cluster.${INVENTORY}.ini -vvvv
