#!/usr/bin/env bash

set -e

CWD="$(cd "$(dirname "$0")"/.. && pwd)"
NAMESPACE="xerberusteam"

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

VERSION=$(grep 'version\s*=' "$CWD/node/Cargo.toml" | head -1 | cut -d '"' -f2)
VERSION_LABEL="full-node-$VERSION"
VERSION_TAG="ghcr.io/$NAMESPACE/xerberus-node-v2:$VERSION_LABEL"
LATEST_LABEL="full-node-latest"
LATEST_TAG="ghcr.io/$NAMESPACE/xerberus-node-v2:$LATEST_LABEL"

echo "Publishing Docker images to GitHub Container Registry"
echo "Version tag: $VERSION_TAG"
echo "Latest tag: $LATEST_TAG"

echo "Publishing $VERSION_TAG"
docker push "$VERSION_TAG"

echo "Publishing $LATEST_TAG"
docker push "$LATEST_TAG"

echo "Done! Images have been successfully published." 

# chmod +x scripts/publish.sh 