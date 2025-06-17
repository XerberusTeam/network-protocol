# Risk Ratings Pallet - JavaScript Client

A comprehensive JavaScript client for interacting with the Risk Ratings Substrate pallet. This client provides easy-to-use methods for submitting signed extrinsics to update risk scores and querying scores via RPC calls.

## Features

- ✅ **Submit Signed Extrinsics**: Update risk scores for different partitions
- ✅ **RPC Query Methods**: Retrieve scores and call pallet functions
- ✅ **SCALE Encoding/Decoding**: Handle Substrate's native encoding format
- ✅ **Account Management**: Create and manage signing accounts
- ✅ **Event Processing**: Monitor transaction events and status
- ✅ **Error Handling**: Comprehensive error reporting and handling

## Prerequisites

- Node.js 16+ with ES modules support
- A running Substrate node with the Risk Ratings pallet at `ws://127.0.0.1:9944`
- The Risk Ratings pallet should be configured in your runtime

## Installation

```bash
npm install
```

## Quick Start

### Run the Full Demo

```bash
npm start
# or
npm run demo
```

This runs a complete demonstration that:
1. Tests RPC connectivity
2. Submits score updates via signed extrinsics
3. Queries and verifies the results
4. Shows account summary

### Update Scores Only

```bash
npm run update
```

Demonstrates submitting signed extrinsics to update risk scores for different partitions.

### Query Scores Only

```bash
npm run query
```

Demonstrates querying scores via RPC calls and manual hex decoding.

## Usage Examples

### Basic Client Usage

```javascript
import RiskRatingsClient from './riskRatingsClient.js';

const client = new RiskRatingsClient();
await client.initialize();

// Create account for signing
const alice = client.createAccount('//Alice');

// Update a score
const txHash = await client.updateScore(alice, 'production', 95);
console.log('Transaction hash:', txHash);

// Query scores
const scores = await client.getScores('production');
console.log('Scores:', scores);

// Test RPC
const message = await client.sayHello();
console.log('Hello message:', message);

await client.disconnect();
```

### Manual RPC Calls with curl

You can also make direct RPC calls using curl:

```bash
# Say hello
curl -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "method": "state_call",
  "params": ["RiskRatingApi_say_hello", "0x"],
  "id": 1
}' http://127.0.0.1:9944

# Get scores for "test" partition
curl -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "method": "state_call",
  "params": ["RiskRatingApi_get_scores", "0x1074657374"],
  "id": 1
}' http://127.0.0.1:9944
```

### SCALE Encoding Reference

When making manual RPC calls, partition names need to be SCALE-encoded:

- `"test"` → `"0x1074657374"`
- `"prod"` → `"0x1070726f64"`
- `"dev"` → `"0x03646576"`
- `"staging"` → `"0x1c73746167696e67"`

## API Reference

### RiskRatingsClient

#### Constructor
```javascript
new RiskRatingsClient(nodeUrl = 'ws://127.0.0.1:9944')
```

#### Methods

- `async initialize()` - Connect to the node and initialize the client
- `createAccount(seed)` - Create/import an account for signing transactions
- `async updateScore(account, partition, score)` - Submit signed extrinsic to update score
- `async sayHello()` - Call the say_hello RPC method
- `async getScores(partition)` - Query scores for a partition via RPC
- `decodeHexResponse(hexResponse)` - Manually decode SCALE-encoded hex responses
- `async getAccountInfo(address)` - Get account balance and nonce information
- `async disconnect()` - Disconnect from the node

## Project Structure

```
├── riskRatingsClient.js     # Main client implementation
├── examples/
│   ├── fullDemo.js          # Complete workflow demonstration
│   ├── updateScores.js      # Extrinsic submission examples
│   └── queryScores.js       # RPC query examples
├── package.json             # Dependencies and scripts
└── README.md               # This file
```

## Risk Ratings Pallet Integration

This client is designed to work with a Substrate runtime that includes the Risk Ratings pallet with:

### Extrinsics
- `riskRatings.updateScore(partition: Vec<u8>, score: u32)` - Update risk score

### RPC Methods
- `RiskRatingApi_say_hello()` - Returns greeting message
- `RiskRatingApi_get_scores(partition: String)` - Returns scores for partition

### Events
- `riskRatings.ScoreUpdated` - Emitted when a score is updated

## Troubleshooting

### Connection Issues
- Ensure your Substrate node is running on `ws://127.0.0.1:9944`
- Check that the Risk Ratings pallet is included in your runtime
- Verify the runtime APIs are properly implemented

### Transaction Failures
- Check account balance (ensure sufficient funds for transaction fees)
- Verify the partition name length (max 100 bytes)
- Ensure the pallet hasn't reached the maximum scores limit (1000 per partition)

### RPC Errors
- Verify the runtime API methods are properly exposed
- Check that the method names match exactly: `RiskRatingApi_say_hello`, `RiskRatingApi_get_scores`
- Ensure proper SCALE encoding for string parameters

## Dependencies

- `@polkadot/api` - Polkadot.js API for Substrate interaction
- `@polkadot/types` - Type definitions and SCALE codec
- `@polkadot/keyring` - Account management and signing
- `@polkadot/util-crypto` - Cryptographic utilities

## License

MIT
