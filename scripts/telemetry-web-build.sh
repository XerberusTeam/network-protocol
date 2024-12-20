#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/../telemetry-web && pwd)"
PLATFORM="linux/amd64"
NAMESPACE="xerberusteam"

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH              Set the current working directory (default: $CWD)"
    echo "  --platform PLATFORM     Set the build platform (default: $PLATFORM)"
    echo "  --namespace NAMESPACE   Set the namespace for the image (default: $NAMESPACE)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        --platform) PLATFORM="$2"; shift ;;
        --namespace) NAMESPACE="$2"; shift ;;
        -h|--help) usage ;;  # Display help
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

CONTEXT_DIR=$CWD
DOCKERFILE="$CWD/Dockerfile"
LATEST_LABEL="telemetry-web-latest"
LATEST_TAG="ghcr.io/$NAMESPACE/xerberus-node:$LATEST_LABEL"

echo building "$LATEST_TAG" from "$DOCKERFILE" in "$CONTEXT_DIR"
docker build -f "$DOCKERFILE" --platform "$PLATFORM" -t "$LATEST_TAG" "$CONTEXT_DIR" \
    --label "org.opencontainers.image.title=xerberus-node" \
    --label "org.opencontainers.image.version=latest" \
    --label "org.opencontainers.image.source=https://github.com/xerberusteam/network-protocol" \
    --label "org.opencontainers.image.description=xerberus-node-telemetry-web" \
    --label "org.opencontainers.image.licenses=Apache-2.0"
