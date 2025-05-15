# Substrate Solo Chain Node Setup Guide

## Table of Contents

- [Introduction](#introduction)
- [Single Node Development Mode](#single-node-development-mode)
- [Multi-Node Local Testnet Setup](#multi-node-local-testnet-setup)
  - [Step 1: Create Directory Structure](#step-1-create-directory-structure)
  - [Step 2: Generate Node Keys](#step-2-generate-node-keys)
  - [Step 3: Generate Validator Keys](#step-3-generate-validator-keys)
  - [Step 4: Create and Configure Chain Specification](#step-4-create-and-configure-chain-specification)
  - [Step 5: Run the Bootnode](#step-5-run-the-bootnode)
  - [Step 6: Run Validator Nodes](#step-6-run-validator-nodes)
  - [Step 7: Insert Validator Keys](#step-7-insert-validator-keys)
  - [Step 8: Run Light Node (Optional)](#step-8-run-light-node-optional)
  - [Step 9: Verify Key Insertion](#step-9-verify-key-insertion)
  - [Step 10: Connect to Your Network](#step-10-connect-to-your-network)

## Introduction

This guide provides step-by-step instructions for setting up a Substrate-based solo chain, both for development and for a multi-node testnet environment.

## Single Node Development Mode

For quick development and testing, you can run a single development node:

```bash
# Start a development node
./target/release/solochain-template-node --dev

# To purge the chain state and start fresh
./target/release/solochain-template-node purge-chain --dev -y
```

## Multi-Node Local Testnet Setup

This section guides you through setting up a local testnet with multiple nodes including validators.

### Step 1: Create Directory Structure

First, set up the necessary directory structure for node data:

```bash
mkdir -p local-chain-state/nodes/{xerberus-bootnode,xerberus-validator-1,xerberus-validator-2,xerberus-validator-3}
```

### Step 2: Generate Node Keys

Generate P2P communication keys for each node:

```bash
# These keys are used for P2P communication between nodes
subkey generate-node-key > local-chain-state/keys/bootnode/node-key
subkey generate-node-key > local-chain-state/keys/validator1/node-key
subkey generate-node-key > local-chain-state/keys/validator2/node-key
subkey generate-node-key > local-chain-state/keys/validator3/node-key
subkey generate-node-key > local-chain-state/keys/lightnode/node-key
```

### Step 3: Generate Validator Keys

For each validator, generate two types of keys:

```bash
# 1. Aura keys (Sr25519) - For block production
subkey generate --scheme Sr25519

# 2. GRANDPA keys (Ed25519) - For block finalization
subkey generate --scheme Ed25519
```

**Important**: Securely save both the seeds/mnemonics and public keys from these commands.

### Step 4: Create and Configure Chain Specification

Generate and configure your chain specification:

```bash
# Generate base chain specification
./target/release/solochain-template-node build-spec --chain local > chain-spec.json

# Edit chain-spec.json to add your validators' keys to the Aura and GRANDPA authority sets
# Look for "aura" and "grandpa" sections and add the public keys generated in Step 3

# Convert the edited chain specification to raw format
./target/release/solochain-template-node build-spec --chain chain-spec.json --raw > chain-spec-raw.json
```

### Step 5: Run the Bootnode

Start the bootnode (first node that other nodes will connect to):

```bash
./target/release/solochain-template-node \
  --chain chain-spec-raw.json \
  --base-path ./local-chain-state/data/bootnode \
  --node-key-file ./local-chain-state/keys/bootnode/node-key \
  --listen-addr /ip4/0.0.0.0/tcp/30333 \
  --public-addr /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWPQJkTNMGQrjE9wTgGV98Ss5QEViorpysieDSTqS9ipri \
  --rpc-port 9933 \
  --rpc-methods=Safe \
  --allow-private-ip \
  --name BootNode
```

### Step 6: Run Validator Nodes

Start each validator node with appropriate configuration:

#### Validator 1

```bash
RUST_LOG=afg=trace,grandpa=debug ./target/release/solochain-template-node \
--chain chain-spec-raw.json \
--base-path ./local-chain-state/data/validator1 \
--node-key-file ./local-chain-state/keys/validator1/node-key \
--port 30334 \
--rpc-port 9934 \
--validator \
--rpc-methods=Unsafe \
--name Validator1 \
--allow-private-ip \
--bootnodes "/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWPQJkTNMGQrjE9wTgGV98Ss5QEViorpysieDSTqS9ipri"
```

#### Validator 2

```bash
RUST_LOG=afg=trace,grandpa=debug ./target/release/solochain-template-node \
--chain chain-spec-raw.json \
--base-path ./local-chain-state/data/validator2 \
--node-key-file ./local-chain-state/keys/validator2/node-key \
--port 30335 \
--rpc-port 9935 \
--validator \
--rpc-methods=Unsafe \
--name Validator2 \
--allow-private-ip \
--bootnodes "/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWPQJkTNMGQrjE9wTgGV98Ss5QEViorpysieDSTqS9ipri"
```

#### Validator 3

```bash
RUST_LOG=afg=trace,grandpa=debug ./target/release/solochain-template-node \
--chain chain-spec-raw.json \
--base-path ./local-chain-state/data/validator3 \
--node-key-file ./local-chain-state/keys/validator3/node-key \
--port 30336 \
--rpc-port 9936 \
--validator \
--rpc-methods=Unsafe \
--name Validator3 \
--allow-private-ip \
--bootnodes "/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWPQJkTNMGQrjE9wTgGV98Ss5QEViorpysieDSTqS9ipri"
```

### Step 7: Insert Validator Keys

Insert Aura and GRANDPA keys into each validator node:

#### Validator 1

```bash
# Aura Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["aura","candy cushion purse birth hint hero lens frown intact hope gesture toe","0xde947f4d9e0569e189f173c2cc9e85ac3dcc14c60e9cd6f3e254158efd45da0e"]}' \
http://127.0.0.1:9934

# GRANDPA Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["gran","field shed clown easy junk jeans before already time actual chimney relax","0xf5d53040be5faccea4e810727e4052c9ba9058b949a35f52e8a3c783603db516"]}' \
http://127.0.0.1:9934
```

#### Validator 2

```bash
# Aura Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["aura","family stuff wreck snow lazy cannon used liar balcony solid crop pencil","0xb42291db975f6ac6758771400c5ecbc2cd151ddb293de6cead5908b303079d23"]}' \
http://127.0.0.1:9935

# GRANDPA Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["gran","view defense shoot open spin mammal dune item buffalo wool suit truly","0x614221ebd595c221f8395ccf5efd489d399cfb970f0cb7754bf02808d681c8d0"]}' \
http://127.0.0.1:9935
```

#### Validator 3

```bash
# Aura Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["aura","essence adjust east all nuclear crowd before much tenant frog table sick","0x748cde0debf353773f6a7746f80be59e1ec85174cba9099a87eaca98f84d1505"]}' \
http://127.0.0.1:9936

# GRANDPA Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["gran","border guide list vanish draw true announce derive sort struggle eyebrow grow","0x1bea0d82a952f7775985438e79aabf4f05db8c04a24e6328438a13c3f6e6ea23"]}' \
http://127.0.0.1:9936
```

### Step 8: Run Light Node (Optional)

Start a non-validator node:

```bash
RUST_LOG=afg=trace,grandpa=debug ./target/release/solochain-template-node \
--chain chain-spec-raw.json \
--base-path ./local-chain-state/data/lightnode \
--node-key-file ./local-chain-state/keys/lightnode/node-key \
--port 30400 \
--rpc-port 9960 \
--rpc-methods=Unsafe \
--name LightNode \
--allow-private-ip \
--bootnodes "/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWPQJkTNMGQrjE9wTgGV98Ss5QEViorpysieDSTqS9ipri"
```

### Step 9: Verify Key Insertion

Check if keys were properly inserted:

#### Validator 1

```bash
# Verify Aura Key
curl -H "Content-Type: application/json" -d '{
  "id":1,
  "jsonrpc":"2.0",
  "method":"author_hasKey",
  "params":["0x72a4fde8aeeab2fd90d577b588418eb0e175ef3f7984c10e11f887a2a158f07c", "aura"]
}' http://127.0.0.1:9934

# Verify GRANDPA Key
curl -H "Content-Type: application/json" -d '{
  "id":1,
  "jsonrpc":"2.0",
  "method":"author_hasKey",
  "params":["0x4e558158a2afd092c7f655c2d63d210a36902ae76f7b124a44720f28063521c5", "gran"]
}' http://127.0.0.1:9934
```

#### Validator 2

```bash
# Verify Aura Key
curl -H "Content-Type: application/json" -d '{
  "id":1,
  "jsonrpc":"2.0",
  "method":"author_hasKey",
  "params":["0x96411bf7a592e11b8b86059fa7b2dc683d07b2217c650481198221bfc6ca3152", "aura"]
}' http://127.0.0.1:9935

# Verify GRANDPA Key
curl -H "Content-Type: application/json" -d '{
  "id":1,
  "jsonrpc":"2.0",
  "method":"author_hasKey",
  "params":["0x7935ec050ad8b02d103bb0e7c30a60da0d93aa14baf119255f8c95a8310cb71f", "gran"]
}' http://127.0.0.1:9935
```

#### Validator 3

```bash
# Verify Aura Key
curl -H "Content-Type: application/json" -d '{
  "id":1,
  "jsonrpc":"2.0",
  "method":"author_hasKey",
  "params":["0x045885cbad88ff2539e9371833ec3ca2bd114bfdfdd34c869798e32340c65727", "aura"]
}' http://127.0.0.1:9936

# Verify GRANDPA Key
curl -H "Content-Type: application/json" -d '{
  "id":1,
  "jsonrpc":"2.0",
  "method":"author_hasKey",
  "params":["0x4b9667a0603960b40d17590c29ecc28bbc46614ba1246db45d2bd3b8b0852f5f", "gran"]
}' http://127.0.0.1:9936
```

### Step 10: Connect to Your Network

Connect to your nodes via PolkadotJS Apps:

- Bootnode WebSocket: `ws://127.0.0.1:9944`
- Validator1 WebSocket: `ws://127.0.0.1:9944` (same port as HTTP RPC when running natively)
- Validator2 WebSocket: `ws://127.0.0.1:9935`
- Validator3 WebSocket: `ws://127.0.0.1:9936`
- Lightnode WebSocket: `ws://127.0.0.1:9960`

Example URL: [https://polkadot.js.org/apps/?rpc=ws://127.0.0.1:9934](https://polkadot.js.org/apps/?rpc=ws://127.0.0.1:9934)

---

## Related Resources

- [Testnet Configuration](testnet-configuration.md)
- [Runtime API Guide](../development/runtime-api-guide.md) 