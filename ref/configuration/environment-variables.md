# Xerberus Node Environment Variables

## Table of Contents

- [Introduction](#introduction)
- [Logging Variables](#logging-variables)
- [Node Configuration Variables](#node-configuration-variables)
- [Docker Compose Environment Variables](#docker-compose-environment-variables)
- [Usage Examples](#usage-examples)

## Introduction

This document outlines the environment variables that can be used to configure Xerberus nodes. These variables can be set directly in your shell environment, in a `.env` file, or as part of a Docker Compose configuration.

## Logging Variables

### RUST_LOG

The `RUST_LOG` variable controls the logging verbosity of different components.

```bash
# Default logging (recommended for production)
RUST_LOG=info

# Verbose logging (useful for debugging)
RUST_LOG=debug

# Component-specific logging
RUST_LOG=afg=trace,grandpa=debug,libp2p=debug,sub-libp2p=debug,sync=debug,gossip=debug,peerset=debug,network=debug
```

Key components you can configure:
- `afg`: Authority finality gadget (part of Grandpa)
- `grandpa`: GRANDPA finality gadget
- `libp2p`: Networking layer
- `sub-libp2p`: Substrate networking
- `sync`: Block synchronization
- `gossip`: Network message propagation
- `peerset`: Peer management
- `network`: Overall network operations

## Node Configuration Variables

These variables can be used with the `--env` or `-e` flags in Docker/Docker Compose:

```bash
# Node identity
NODE_NAME=xerberus-validator-1

# Base data directory 
DATA_PATH=/data/nodes/validator1

# Ports
P2P_PORT=30333
RPC_PORT=9933
WS_PORT=9944

# Chain specification
CHAIN_SPEC=/data/chain-spec-raw.json
```

## Docker Compose Environment Variables

These variables are specific to Docker Compose configurations:

```yaml
environment:
  # Logging
  - RUST_LOG=info,afg=trace,grandpa=debug,libp2p=debug,sub-libp2p=debug,sync=debug
  
  # Metadata for logs
  - NODE=xerberus-validator-1
  
  # Container resource limits
  - RUST_BACKTRACE=1
```

## Usage Examples

### Setting Environment Variables for Node Execution

```bash
# Set logging level
export RUST_LOG=info,sync=debug,network=debug

# Run the node
./target/release/solochain-template-node --validator --name my-validator
```

### Using Environment Variables in Docker Compose

```yaml
services:
  xerberus-validator:
    image: xerberus-node-v2:latest
    environment:
      - RUST_LOG=info,sub-libp2p=debug,sync=debug
      - NODE=xerberus-validator-1
    command: |
      --validator
      --name ${NODE_NAME:-xerberus-validator}
      --rpc-cors all
```

### Using a .env File

Create a `.env` file in your project directory:

```
RUST_LOG=info,sync=debug
NODE_NAME=xerberus-validator-1
P2P_PORT=30333
RPC_PORT=9933
WS_PORT=9944
```

Then in your Docker Compose file:

```yaml
services:
  xerberus-validator:
    env_file: .env
    ports:
      - "${P2P_PORT}:30333"
      - "${RPC_PORT}:9933"
      - "${WS_PORT}:9944"
```

---

## Related Resources

- [Node Setup Guide](../node/node-setup-guide.md)
- [Network Parameters](network-parameters.md) 