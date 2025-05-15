# Xerberus Testnet Configuration Guide

## Table of Contents

- [Introduction](#introduction)
- [Validator Key Configuration](#validator-key-configuration)
  - [Validator 1](#validator-1)
  - [Validator 2](#validator-2)
  - [Validator 3](#validator-3)
- [Key Verification](#key-verification)
- [Network Troubleshooting](#network-troubleshooting)

## Introduction

This guide provides the configuration details for the Xerberus testnet, including validator keys and how to insert them into your nodes. These instructions assume you've already set up the basic node infrastructure using Docker Compose or direct node execution.

## Validator Key Configuration

After starting your validator nodes, you'll need to insert the Aura (block production) and GRANDPA (finalization) keys. Use the commands below to insert the test keys into each validator.

### Validator 1

From your server where validator 1 is running, execute:

```bash
# Aura Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["aura","ginger decrease bargain member learn business patch royal jacket company swamp tide","0x72a4fde8aeeab2fd90d577b588418eb0e175ef3f7984c10e11f887a2a158f07c"]}' \
http://127.0.0.1:9934

# GRANDPA Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["gran","park aerobic era zero sniff birth seven scorpion kite night axis name","0x4e558158a2afd092c7f655c2d63d210a36902ae76f7b124a44720f28063521c5"]}' \
http://127.0.0.1:9934
```

### Validator 2

From your server where validator 2 is running, execute:

```bash
# Aura Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["aura","picnic dawn day sausage grunt flash endorse child under chaos fuel scorpion","0x96411bf7a592e11b8b86059fa7b2dc683d07b2217c650481198221bfc6ca3152"]}' \
http://127.0.0.1:9935

# GRANDPA Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["gran","basic inch decrease loyal always repair walnut minute carbon fashion addict bridge","0x7935ec050ad8b02d103bb0e7c30a60da0d93aa14baf119255f8c95a8310cb71f"]}' \
http://127.0.0.1:9935
```

### Validator 3

From your server where validator 3 is running, execute:

```bash
# Aura Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["aura","monster brother winter uncle produce verify wet stomach strategy design route rotate","0x045885cbad88ff2539e9371833ec3ca2bd114bfdfdd34c869798e32340c65727"]}' \
http://127.0.0.1:9936

# GRANDPA Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["gran","luggage entry example old vivid addict swap skill electric chest drastic blouse","0x4b9667a0603960b40d17590c29ecc28bbc46614ba1246db45d2bd3b8b0852f5f"]}' \
http://127.0.0.1:9936
```

## Key Verification

You can verify that the keys were properly inserted using the following commands:

```bash
# Verify Aura key for validator 1
curl -H "Content-Type: application/json" -d '{
  "id":1,
  "jsonrpc":"2.0",
  "method":"author_hasKey",
  "params":["0x72a4fde8aeeab2fd90d577b588418eb0e175ef3f7984c10e11f887a2a158f07c", "aura"]
}' http://127.0.0.1:9934

# Verify GRANDPA key for validator 1
curl -H "Content-Type: application/json" -d '{
  "id":1,
  "jsonrpc":"2.0",
  "method":"author_hasKey",
  "params":["0x4e558158a2afd092c7f655c2d63d210a36902ae76f7b124a44720f28063521c5", "gran"]
}' http://127.0.0.1:9934
```

Repeat the above commands for validators 2 and 3, changing the endpoints and keys accordingly.

## Network Troubleshooting

If you encounter issues with your testnet:

1. **Peer Discovery**: Ensure all validators have the correct bootnode information
   ```
   --bootnodes /dns/node-v2.xerberus.io/tcp/30333/ws/p2p/12D3KooWCYKbsQw2r5575MA8YqMhn8AqhVuZkfobPMyoKzEP595t
   ```

2. **Block Production**: Check if your validator is producing blocks:
   ```bash
   curl -H "Content-Type: application/json" -d '{"id":1, "jsonrpc":"2.0", "method":"system_health", "params":[]}' http://127.0.0.1:9934
   ```

3. **Restart a Node**: If a node is experiencing issues, you can restart it:
   ```bash
   docker restart xerberus-validator-1
   ```

4. **Clear Chain Data**: To start fresh, stop the node and clear its data:
   ```bash
   docker compose -f testnet.compose.yaml down
   sudo rm -rf /opt/xerberus/data/nodes/*
   docker compose -f testnet.compose.yaml up -d
   ```

---

## Related Resources

- [Node Setup Guide](node-setup-guide.md)
- [Runtime API Guide](../development/runtime-api-guide.md) 