#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root directory
cd "$PROJECT_ROOT"

# Stop all running containers and remove volumes
echo "Stopping all containers and removing volumes..."
docker-compose -f scripts/localnet.compose.yaml down -v

# Remove all node data directories completely
echo "Removing all node data directories..."
rm -rf local-chain-state/nodes
mkdir -p local-chain-state/nodes/{xerberus-bootnode,xerberus-validator-1,xerberus-validator-2,xerberus-validator-3,xerberus-lightnode}

# Set permissions
echo "Setting proper permissions..."
chmod -R 777 local-chain-state/nodes

# Start containers
echo "Starting containers..."
docker-compose -f scripts/localnet.compose.yaml up -d

echo "Node initialization complete. Check logs with 'docker logs -f xerberus-bootnode'" 