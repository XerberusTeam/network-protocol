# Risk Ratings Pallet

A production-ready FRAME pallet for managing partition-based risk scores with RPC query capabilities.

## Overview

This pallet provides a simple, efficient system for storing and querying risk scores associated with string-based partitions. It's designed for production use with proper validation, comprehensive documentation, and efficient storage.

### Key Features

- **Single Extrinsic**: `update_score` - stores risk scores with automatic timestamp
- **Two RPC Methods**: `say_hello` and `get_scores` for querying data
- **String-based Partitions**: Use plain strings like "test", "prod", "region-us-east"
- **Production-Ready**: Reasonable storage limits (1000 entries/partition), proper validation
- **Efficient Storage**: Uses Blake2_128Concat hasher for optimal performance
- **Comprehensive Documentation**: Detailed examples and usage instructions

## Storage Structure

The pallet stores data in the following format:

```rust
// Example storage entries:
"test" -> [
    ScoreEntry { score: 12, timestamp: 1 },  // Score 12 at block 1
    ScoreEntry { score: 15, timestamp: 2 },  // Score 15 at block 2
]

"prod" -> [
    ScoreEntry { score: 8, timestamp: 3 },   // Score 8 at block 3
]
```

## Usage Examples

### Extrinsic Calls

```bash
# Store a risk score of 12 for "test" partition
curl -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "method": "riskRatings_updateScore",
  "params": ["test", 12],
  "id": 1
}' http://127.0.0.1:9944

# Store a risk score of 8 for "prod" partition
curl -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "method": "riskRatings_updateScore",
  "params": ["prod", 8],
  "id": 1
}' http://127.0.0.1:9944
```

### RPC Calls

#### Using state_call (Recommended for Production)

```bash
# Get greeting message
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

# Get scores for "prod" partition
curl -H "Content-Type: application/json" -d '{
  "jsonrpc": "2.0",
  "method": "state_call",
  "params": ["RiskRatingApi_get_scores", "0x1070726f64"],
  "id": 1
}' http://127.0.0.1:9944
```

### Understanding SCALE Encoding for Strings

When using `state_call` with string parameters, you need to SCALE-encode the string:

- **"test"** → `"0x1074657374"` (10 = length, 74657374 = "test" in hex)
- **"prod"** → `"0x1070726f64"` (10 = length, 70726f64 = "prod" in hex)
- **"dev"** → `"0x03646576"` (03 = length, 646576 = "dev" in hex)

### Response Format

The RPC response is SCALE-encoded. For example:
```json
{
  "jsonrpc": "2.0",
  "result": "0x040a0000000c000000",
  "id": 1
}
```

Decoding `0x040a0000000c000000`:
- `04` = Vector length (1 entry)
- `0a000000` = Score: 10 (u32 in little endian)
- `0c000000` = Timestamp: 12 (u32 in little endian)

## Development

### Build

```bash
cargo build --package pallet-risk-ratings
```

### Test

```bash
cargo test --package pallet-risk-ratings
```

### Integration

Add to your runtime's `Cargo.toml`:

```toml
pallet-risk-ratings = { path = "../pallets/risk-ratings", default-features = false }
```

Add to your runtime's `lib.rs`:

```rust
impl pallet_risk_ratings::Config for Runtime {
    type RuntimeEvent = RuntimeEvent;
    type WeightInfo = pallet_risk_ratings::weights::SubstrateWeight<Runtime>;
}

// In construct_runtime! macro:
RiskRatings: pallet_risk_ratings,

// In impl_runtime_apis! macro:
impl pallet_risk_ratings::runtime_api::RiskRatingApi<Block> for Runtime {
    fn say_hello() -> Vec<u8> {
        RiskRatings::say_hello()
    }

    fn get_scores(partition: String) -> Vec<pallet_risk_ratings::ScoreEntry> {
        RiskRatings::get_scores(partition)
    }
}
```

## Production Considerations

- **Reasonable Storage Limits**: 1000 entries per partition (sufficient for most use cases)
- **Automatic Timestamps**: Uses block numbers for automatic timestamp tracking
- **Event Emission**: Comprehensive events for monitoring and indexing
- **String-based Partitions**: Easy to use with human-readable partition names
- **Bounded Storage Keys**: Uses BoundedVec for efficient storage and fee calculation

## Data Types

```rust
/// Single risk score entry
pub struct ScoreEntry {
    pub score: u32,      // The risk score value
    pub timestamp: u32,  // Block number when recorded
}

/// Vector of score entries for a partition
pub struct ScoreEntries(pub BoundedVec<ScoreEntry, ConstU32<1000>>);
```

License: MIT-0
