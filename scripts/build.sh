#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
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
VERSION=$(grep 'version\s*=' "$CWD/node/Cargo.toml" | head -1 | cut -d '"' -f2)
VERSION_LABEL="full-node-$VERSION"
VERSION_TAG="ghcr.io/$NAMESPACE/xerberus-node-v2:$VERSION_LABEL"
LATEST_LABEL="full-node-latest"
LATEST_TAG="ghcr.io/$NAMESPACE/xerberus-node-v2:$LATEST_LABEL"
LOCAL_TAG="xerberus-node-v2:latest"

echo "Building Docker image with tags:"
echo "  - $VERSION_TAG"
echo "  - $LATEST_TAG"
echo "  - $LOCAL_TAG (for docker-compose)"

# Build once with multiple tags
docker build -f "$DOCKERFILE" --platform "$PLATFORM" \
    -t "$VERSION_TAG" \
    -t "$LATEST_TAG" \
    -t "$LOCAL_TAG" \
    "$CONTEXT_DIR" \
    --label "org.opencontainers.image.title=xerberus-node-v2" \
    --label "org.opencontainers.image.version=$VERSION" \
    --label "org.opencontainers.image.source=https://github.com/xerberusteam/network-protocol" \
    --label "org.opencontainers.image.description=xerberus-node-v2-full-node" \
    --label "org.opencontainers.image.licenses=Apache-2.0"

echo ""
echo "Done! Now you can run the local network with:"
echo "docker-compose -f $CWD/scripts/localnet.compose.yaml up"

# chmod +x scripts/build.sh