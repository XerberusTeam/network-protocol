#!/usr/bin/env bash

set -e

NAMESPACE="xerberusteam"
LABEL="full-node-latest"
TAG="ghcr.io/$NAMESPACE/xerberus-node:$LABEL"

# example:
# - ./scripts/xerberus-node.sh build-spec \
#   --chain chain-spec-plain.json
#   --raw --disable-default-bootnode

docker run -i --rm -v $PWD:/data -w /data $TAG $@