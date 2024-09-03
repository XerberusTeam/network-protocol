#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
NAMESPACE="XerberusTeam"

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH              Set the current working directory (default: $CWD)"
    echo "  --namespace NAMESPACE   Set the namespace for the image (default: $NAMESPACE)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        --namespace) NAMESPACE="$2"; shift ;;
        -h|--help) usage ;;  # Display help
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

VERSION=$(grep '^version\s*=' $CWD/node/Cargo.toml | sed 's/^version\s*=\s*//; s/^"//; s/"$//; s/^'"'"'//; s/'"'"'$//')
VERSION_LABEL="full-node-$VERSION"
VERSION_TAG="ghcr.io/$NAMESPACE/xerberus-node:$VERSION_LABEL"
LATEST_LABEL="full-node-latest"
LATEST_TAG="ghcr.io/$NAMESPACE/xerberus-node:$LATEST_LABEL"

echo publishing "$VERSION_TAG"
docker push "$VERSION_TAG"
echo publishing "$LATEST_TAG"
docker push "$LATEST_TAG"
