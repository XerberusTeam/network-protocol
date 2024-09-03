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
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

VERSION=$(grep '^version\s*=' $CWD/node/Cargo.toml | sed 's/^version\s*=\s*//; s/^"//; s/"$//; s/^'"'"'//; s/'"'"'$//')
VERSION_LABEL="full-node-$VERSION"
VERSION_TAG="xerberus/xerberus-node:$LABEL"
LATEST_LABEL="full-node-latest"
LATEST_TAG="xerberus/xerberus-node:$LABEL"

echo publishing "$VERSION_TAG"
docker push "$VERSION_TAG"
echo publishing "$LATEST_TAG"
docker push "$LATEST_TAG"
