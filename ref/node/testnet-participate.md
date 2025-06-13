# Participating in Xerberus Network

This guide helps you run a Xerberus light node using Docker Compose. Running a node contributes to the network's resilience and allows you to interact with the blockchain.

## Prerequisites

- Docker and Docker Compose installed
- Basic terminal/command line knowledge
- 2+ CPU cores and 4GB+ RAM recommended

## Quick Start

### Step 1: Download the Docker Compose File

Download the `join-testnet.compose.yaml` file:

```bash
# ToDo: Update the branch here, post main merge
curl -O https://raw.githubusercontent.com/xerberusteam/network-protocol/version-update/scripts/join-testnet.compose.yaml
```

Or manually download and save it to your preferred location.

### Step 2: Set Up Data Directory

Create a directory for the node data where you have the compose file:

```bash
# Create directory structure
mkdir -p ./xerberus-node/data
```

### Step 3: Customize Your Node (Optional)

Open the `join-testnet.compose.yaml` file and change:
- `--name your-xerberus-node` to a unique name for your node

### Step 4: Run the Node

From the directory containing your compose file:

```bash
docker compose -f join-testnet.compose.yaml up -d
```

### Step 5: Check Node Status

```bash
docker logs -f xerberus-light-node
```

Your node should start syncing with the network. Look for messages indicating block imports.

## Troubleshooting

### Volume Mount Issues
If you see "failed to mount local volume" errors:

```bash
# Make sure the directory exists in the same location as your compose file
ls -la ./xerberus-node/data

# If it doesn't exist:
mkdir -p ./xerberus-node/data

# Remove any existing Docker volume if there was a failed attempt
docker volume rm $(docker compose -f join-testnet.compose.yaml ps -q)_xerberus_nodes_data

# Then retry running the container
docker compose -f join-testnet.compose.yaml up -d
```

### ARM-based Macs (M1/M2)
The compose file includes `platform: linux/amd64` which enables emulation. This may impact performance but allows compatibility.

### Network Connectivity
- Default P2P port is 30333
- Default RPC ports are 9933/9944
- Ensure these ports are accessible if you want external connections

For more detailed configuration options, refer to our [Node Setup Guide](node-setup-guide.md). 