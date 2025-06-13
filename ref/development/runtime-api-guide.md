# Substrate Runtime API Interaction Guide

## Table of Contents

- [Introduction](#introduction)
- [Basic Runtime API Call Example](#basic-runtime-api-call-example)
- [Calling Runtime API with Parameters](#calling-runtime-api-with-parameters)
- [Retrieving Collections](#retrieving-collections)
- [Understanding the Command Pipeline](#understanding-the-command-pipeline)
- [Notes About Parameters](#notes-about-parameters)
- [Further Examples](#further-examples)

## Introduction

Runtime APIs allow you to call functions in your runtime directly through RPC. The examples below use curl to make HTTP requests to a running node.

The general format for runtime API calls is:
```
state_call + API_name + API_method + hex_encoded_parameters
```

## Basic Runtime API Call Example

This example calls the "say_hello" method from the "RiskRatingApi":

```bash
# The "0x" parameter is an empty scale-encoded parameter
curl -s -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "state_call",
  "params": ["RiskRatingApi_say_hello", "0x"]
}' http://127.0.0.1:9944 | jq -r .result | sed 's/^0x//' | xxd -r -p
```

## Calling Runtime API with Parameters

### Example: Get asset with ID 0

The "0x00000000" parameter is the scale-encoded asset ID (0 in this case):

```bash
curl -s -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "state_call",
  "params": ["RiskRatingApi_get_asset", "0x00000000"]
}' http://127.0.0.1:9944 | jq -r .result | sed 's/^0x//' | xxd -r -p
```

Example output:
```json
{"id": 0, "name": "ff", "symbol": "ff", "description": "ff", "creator": "5GrwvaEF...", "createdAt": 8}
```

## Retrieving Collections

This example retrieves all assets in the system:

```bash
# The "0x" parameter is an empty scale-encoded parameter
curl -s -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "state_call",
  "params": ["RiskRatingApi_get_all_assets", "0x"]
}' http://127.0.0.1:9944 | jq -r .result | sed 's/^0x//' | xxd -r -p
```

Example output:
```json
[{"id": 0, "name": "ff", "symbol": "ff", "description": "ff", "creator": "5GrwvaEF...", "createdAt": 8}]
```

## Understanding the Command Pipeline

The curl commands above use some post-processing to make the results readable:

1. `curl -s`: Makes the request silently (no progress or error messages)
2. `jq -r .result`: Extracts just the "result" field from the JSON response
3. `sed 's/^0x//'`: Removes the leading "0x" from the hex string
4. `xxd -r -p`: Converts the hex string back to readable text

## Notes About Parameters

- Parameters must be SCALE encoded in hex format
- `0x00000000` = SCALE encoded 32-bit integer with value 0
- `0x` = Empty parameter
- For complex types, you'll need a SCALE encoder/decoder library to prepare inputs
  - Polkadot.js offers utilities for this in JavaScript environments

## Further Examples

To call your own custom runtime APIs, replace "RiskRatingApi_method_name" with your API name and method, and provide the properly encoded parameters.

The format is always: `YourApiName_your_method_name`

### Common API Patterns

Here are some common patterns you might use:

#### Querying Storage Items
```bash
curl -s -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "state_call",
  "params": ["YourStorageApi_get_item", "0x<encoded_key>"]
}' http://127.0.0.1:9944 | jq -r .result | sed 's/^0x//' | xxd -r -p
```

#### Calling Runtime Functions
```bash
curl -s -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "state_call",
  "params": ["YourRuntimeApi_calculate_something", "0x<encoded_parameters>"]
}' http://127.0.0.1:9944 | jq -r .result | sed 's/^0x//' | xxd -r -p
```

---

## Related Resources

- [Node Setup Guide](../node/node-setup-guide.md)
- [Network Parameters](../configuration/network-parameters.md) 