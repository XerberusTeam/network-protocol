//! Runtime API for the Risk Ratings pallet.
//!
//! This module defines the runtime API that enables RPC calls to query
//! risk rating data from external clients.

use sp_api::decl_runtime_apis;
use sp_std::prelude::*;
use crate::ScoreEntry;

decl_runtime_apis! {
    /// Runtime API for the Risk Ratings pallet.
    ///
    /// This API provides methods for querying risk rating data via RPC calls.
    /// It's designed to be simple and efficient for production use.
    pub trait RiskRatingApi {
        /// Returns a greeting message for testing
        fn say_hello() -> Vec<u8>;

        /// Get score entries for a specific partition
        /// Returns real data if partition exists, otherwise returns dummy data for debugging
        fn get_scores(partition: Vec<u8>) -> Vec<ScoreEntry>;
    }
}
