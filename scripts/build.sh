#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
PLATFORM="linux/amd64"

usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --cwd PATH          Set the current working directory (default: $CWD)"
    echo "  --platform PLATFORM Set the build platform (default: $PLATFORM)"
    exit 1
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --cwd) CWD="$2"; shift ;;
        --platform) PLATFORM="$2"; shift ;;
        -h|--help) usage ;;  # Display help
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

CONTEXT_DIR=$CWD
DOCKERFILE="$CWD/Dockerfile"
VERSION=$(grep '^version\s*=' $CWD/node/Cargo.toml | sed 's/^version\s*=\s*//; s/^"//; s/"$//; s/^'"'"'//; s/'"'"'$//')
VERSION_LABEL="full-node-$VERSION"
VERSION_TAG="xerberus/xerberus-node:$LABEL"
LATEST_LABEL="full-node-latest"
LATEST_TAG="xerberus/xerberus-node:$LABEL"

echo building "$VERSION_TAG" from "$DOCKERFILE" in "$CONTEXT_DIR"
docker build -f "$DOCKERFILE" --platform "$PLATFORM" -t "$VERSION_TAG" "$CONTEXT_DIR"

echo building "$LATEST_TAG" from "$DOCKERFILE" in "$CONTEXT_DIR"
docker build -f "$DOCKERFILE" --platform "$PLATFORM" -t "$LATEST_TAG" "$CONTEXT_DIR"
