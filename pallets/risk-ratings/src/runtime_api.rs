//! Runtime API for the Risk Ratings pallet.
//!
//! Provides RPC methods for querying risk rating data using deterministic i128 types.
//! Follows the same pattern as other Substrate runtime APIs for consistency.

use sp_api::decl_runtime_apis;
use sp_std::prelude::*;
use crate::ScoreEntry;

decl_runtime_apis! {
    /// Runtime API for querying risk rating data via RPC
    pub trait RiskRatingApi {
        /// Returns a greeting message for testing pallet integration
        fn say_hello() -> Vec<u8>;

        /// Get score entries for a partition (returns empty vector if none exist)
        /// Uses i128 for deterministic consensus - same as pallet-balances, pallet-staking
        fn get_scores(partition: Vec<u8>) -> Vec<ScoreEntry>;
    }
}
