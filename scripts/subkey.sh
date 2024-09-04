#!/usr/bin/env bash

set -e

# example:
# - ./subkey.sh generate-node-key
# - ./subkey.sh inspect-node-key
# - ./subkey.sh generate
docker run -i parity/subkey $@