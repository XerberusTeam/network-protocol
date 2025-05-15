// #![cfg(feature = "std")]

use sp_std::prelude::*;

use sp_api::decl_runtime_apis;

decl_runtime_apis! {
    /// API for the Risk Ratings Pallet.
    pub trait RiskRatingApi {
        /// Returns a static greeting from the pallet as a vector of bytes.
        fn say_hello() -> Vec<u8>;
        
        /// Get an asset by ID as a JSON-formatted byte string
        fn get_asset(asset_id: u32) -> Option<Vec<u8>>;
        
        /// Get all assets as a JSON array
        fn get_all_assets() -> Vec<u8>;
    }
}
