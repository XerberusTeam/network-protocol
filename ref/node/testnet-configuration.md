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
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["aura","candy cushion purse birth hint hero lens frown intact hope gesture toe","0xde947f4d9e0569e189f173c2cc9e85ac3dcc14c60e9cd6f3e254158efd45da0e"]}' \
http://127.0.0.1:9934

# GRANDPA Key
curl -H "Content-Type: application/json" -d \
'{"id":1,"jsonrpc":"2.0","method":"author_insertKey","params":["gran","field shed clown easy junk jeans before already time actual chimney relax","0xf5d53040be5faccea4e810727e4052c9ba9058b949a35f52e8a3c783603db516"]}' \
http://127.0.0.1:9934
```

### Validator 2

From your server where validator 2 is running, execute:

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

### Validator 3

From your server where validator 3 is running, execute:

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