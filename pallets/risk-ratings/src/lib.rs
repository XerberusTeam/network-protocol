//! # Risk Ratings Pallet
//!
//! A FRAME pallet for managing asset risk ratings and scores. This pallet allows:
//! - Creating and managing assets
//! - Adding risk scores to assets
//! - Querying asset information and scores
//!
//! ## Overview
//!
//! The pallet implements a risk rating system where:
//! 1. Assets can be created with basic information
//! 2. Risk scores can be added to assets over time
//! 3. Historical scores are maintained for analysis
//!
//! ## Storage
//! - Assets: Map of asset IDs to Asset structs
//! - AssetScores: Map of asset IDs to their historical scores
//! - NextAssetId: Counter for generating unique asset IDs
//!
//! ## Extrinsics
//! - create_asset: Create a new asset
//! - remove_asset: Remove an existing asset
//! - add_score: Add a risk score to an asset

#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

pub mod weights;
pub use weights::*;

// #[cfg(feature = "std")]
pub mod runtime_apis;

#[frame_support::pallet]
pub mod pallet {
    use super::*;
    use frame_support::pallet_prelude::*;
    use frame_system::pallet_prelude::*;
    use sp_runtime::traits::SaturatedConversion;
    use sp_std::prelude::*;
    
    // Import necessary std-like types for no_std environment
    #[cfg(feature = "std")]
    use std::string::String;
    #[cfg(feature = "std")]
    use std::format;
    #[cfg(not(feature = "std"))]
    use scale_info::prelude::string::String;
    #[cfg(not(feature = "std"))]
    use scale_info::prelude::format;

    /// Struct representing an asset in the system
    /// This is the main data structure stored in the Assets storage map
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct Asset<AccountId> {
        /// Unique identifier for the asset
        pub id: u32,
        /// Name of the asset (bounded to prevent storage abuse)
        pub name: BoundedVec<u8, ConstU32<100>>,
        /// Symbol/ticker of the asset (bounded to prevent storage abuse)
        pub symbol: BoundedVec<u8, ConstU32<10>>,
        /// Description of the asset (bounded to prevent storage abuse)
        pub description: BoundedVec<u8, ConstU32<500>>,
        /// The account that created this asset
        pub creator: AccountId,
        /// Timestamp when the asset was created (block number)
        pub created_at: u32,
    }

    /// Struct representing a single risk score entry for an asset
    /// This is stored in the AssetScores storage map
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct ScoreEntry {
        /// The risk score value
        pub score: u32,
        /// Block number when the score was recorded
        pub timestamp: u32,
        /// Additional metadata about the score (bounded to prevent storage abuse)
        pub metadata: BoundedVec<u8, ConstU32<200>>,
    }

    /// Bounded vector of score entries with a maximum length
    /// This is used to limit the number of scores stored per asset
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct BoundedScoreEntries(pub BoundedVec<ScoreEntry, ConstU32<1000>>);

    /// The pallet's configuration trait
    /// This is where we declare types and constants that the pallet depends on
    #[pallet::pallet]
    pub struct Pallet<T>(_);

    #[pallet::config]
    pub trait Config: frame_system::Config {
        /// The type that will be used for Event variants
        type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
        /// Type for weight information
        type WeightInfo: WeightInfo;
    }

    /// Storage for all assets
    /// Uses Blake2_128Concat hasher for efficient key-value storage
    #[pallet::storage]
    pub type Assets<T: Config> = StorageMap<_, Blake2_128Concat, u32, Asset<T::AccountId>>;

    /// Counter for generating unique asset IDs
    /// Starts at 0 and increments for each new asset
    #[pallet::storage]
    pub type NextAssetId<T> = StorageValue<_, u32, ValueQuery>;

    /// Storage for asset scores (time series data)
    /// Maps asset IDs to their historical scores
    #[pallet::storage]
    pub type AssetScores<T> = StorageMap<_, Blake2_128Concat, u32, BoundedScoreEntries>;

    /// Events emitted by this pallet
    /// These help external entities track what happened in the chain
    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        /// Emitted when a new asset is created
        AssetCreated {
            asset_id: u32,
            creator: T::AccountId,
        },
        /// Emitted when an asset is removed
        AssetRemoved {
            asset_id: u32,
            remover: T::AccountId,
        },
        /// Emitted when a new score is added for an asset
        ScoreAdded {
            asset_id: u32,
            score: u32,
            timestamp: u32,
        },
    }

    /// Custom errors that can occur in this pallet
    #[pallet::error]
    pub enum Error<T> {
        /// Asset not found in storage
        AssetNotFound,
        /// Not authorized to perform the action
        NotAuthorized,
        /// Asset name exceeds maximum length
        NameTooLong,
        /// Asset symbol exceeds maximum length
        SymbolTooLong,
        /// Asset description exceeds maximum length
        DescriptionTooLong,
        /// Score metadata exceeds maximum length
        MetadataTooLong,
        /// Maximum number of assets reached (u32 overflow)
        AssetIdOverflow,
        /// Maximum number of scores reached for an asset
        MaxScoresReached,
    }

    /// Dispatchable functions (callable extrinsics)
    /// These are the functions that users can call to interact with the pallet
    #[pallet::call]
    impl<T: Config> Pallet<T> {
        /// Create a new asset
        /// This is an extrinsic that can be called by any signed account
        #[pallet::call_index(0)]
        #[pallet::weight(T::WeightInfo::do_something())]
        pub fn create_asset(
            origin: OriginFor<T>,
            name: Vec<u8>,
            symbol: Vec<u8>,
            description: Vec<u8>,
        ) -> DispatchResult {
            // Verify the caller is a signed account
            let creator = ensure_signed(origin)?;

            // Convert inputs to bounded vectors to prevent storage abuse
            let bounded_name = BoundedVec::<u8, ConstU32<100>>::try_from(name)
                .map_err(|_| Error::<T>::NameTooLong)?;
            let bounded_symbol = BoundedVec::<u8, ConstU32<10>>::try_from(symbol)
                .map_err(|_| Error::<T>::SymbolTooLong)?;
            let bounded_description = BoundedVec::<u8, ConstU32<500>>::try_from(description)
                .map_err(|_| Error::<T>::DescriptionTooLong)?;

            // Get and increment the next asset ID
            let asset_id = NextAssetId::<T>::get();
            let next_asset_id = asset_id.checked_add(1).ok_or(Error::<T>::AssetIdOverflow)?;

            // Create the new asset
            let asset = Asset {
                id: asset_id,
                name: bounded_name,
                symbol: bounded_symbol,
                description: bounded_description,
                creator: creator.clone(),
                created_at: frame_system::Pallet::<T>::block_number().saturated_into::<u32>(),
            };

            // Store the asset
            Assets::<T>::insert(asset_id, asset);
            NextAssetId::<T>::put(next_asset_id);

            // Initialize empty scores vector
            AssetScores::<T>::insert(asset_id, BoundedScoreEntries(BoundedVec::new()));

            // Emit event
            Self::deposit_event(Event::AssetCreated { asset_id, creator });

            Ok(())
        }

        /// Remove an asset
        /// This is an extrinsic that can only be called by the asset creator
        #[pallet::call_index(1)]
        #[pallet::weight(T::WeightInfo::do_something())]
        pub fn remove_asset(origin: OriginFor<T>, asset_id: u32) -> DispatchResult {
            // Verify the caller is a signed account
            let who = ensure_signed(origin)?;

            // Get the asset and verify ownership
            let asset = Assets::<T>::get(asset_id).ok_or(Error::<T>::AssetNotFound)?;
            ensure!(asset.creator == who, Error::<T>::NotAuthorized);

            // Remove the asset and its scores
            Assets::<T>::remove(asset_id);
            AssetScores::<T>::remove(asset_id);

            Self::deposit_event(Event::AssetRemoved {
                asset_id,
                remover: who,
            });

            Ok(())
        }

        /// Add a new score for an asset
        /// This is an extrinsic that can be called by any signed account
        #[pallet::call_index(2)]
        #[pallet::weight(T::WeightInfo::do_something())]
        pub fn add_score(
            origin: OriginFor<T>,
            asset_id: u32,
            score: u32,
            metadata: Vec<u8>,
        ) -> DispatchResult {
            // Verify the caller is a signed account
            ensure_signed(origin)?;

            // Verify asset exists
            ensure!(
                Assets::<T>::contains_key(asset_id),
                Error::<T>::AssetNotFound
            );

            // Convert metadata to bounded vector
            let bounded_metadata = BoundedVec::<u8, ConstU32<200>>::try_from(metadata)
                .map_err(|_| Error::<T>::MetadataTooLong)?;

            // Create new score entry
            let score_entry = ScoreEntry {
                score,
                timestamp: frame_system::Pallet::<T>::block_number().saturated_into::<u32>(),
                metadata: bounded_metadata,
            };

            // Update scores storage
            AssetScores::<T>::try_mutate(asset_id, |scores| -> DispatchResult {
                let bounded_scores = scores.as_mut().ok_or(Error::<T>::AssetNotFound)?;
                bounded_scores
                    .0
                    .try_push(score_entry)
                    .map_err(|_| Error::<T>::MaxScoresReached)?;
                Ok(())
            })?;

            Self::deposit_event(Event::ScoreAdded {
                asset_id,
                score,
                timestamp: frame_system::Pallet::<T>::block_number().saturated_into::<u32>(),
            });

            Ok(())
        }
    }

    /// Internal implementation of helper functions
    impl<T: Config> Pallet<T> {
        /// Format a single asset as a JSON string
        fn format_asset_as_json(asset: &Asset<T::AccountId>) -> String {
            // Create a JSON-formatted string
            let name = String::from_utf8_lossy(&asset.name[..]);
            let symbol = String::from_utf8_lossy(&asset.symbol[..]);
            let description = String::from_utf8_lossy(&asset.description[..]);
            
            // For the creator field, we need the SS58 address
            // The debug representation typically includes the SS58 address in parentheses
            // e.g., "d43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d (5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY)"
            let creator_debug = format!("{:?}", asset.creator);
            
            // Extract the complete SS58 address if available
            let creator_address = match (creator_debug.find('('), creator_debug.find(')')) {
                (Some(start), Some(end)) if end > start => {
                    // Extract content between parentheses - this should be the complete address
                    // Remove leading space if present
                    creator_debug[start+1..end].trim()
                },
                _ => {
                    // If no parentheses or invalid format, use the full debug string
                    &creator_debug
                }
            };
            
            // Create a clean JSON string
            format!(
                r#"{{"id": {}, "name": "{}", "symbol": "{}", "description": "{}", "creator": "{}", "createdAt": {}}}"#,
                asset.id,
                name,
                symbol,
                description,
                creator_address,
                asset.created_at
            )
        }
        
        /// Get asset as JSON-formatted bytes
        pub fn get_asset_as_json_bytes(asset_id: u32) -> Option<Vec<u8>> {
            if let Some(asset) = Self::get_asset(asset_id) {
                let json = Self::format_asset_as_json(&asset);
                // Option: Remove any stray non-printable characters at the beginning.
                let cleaned = json.trim_start_matches('\u{feff}'); // removes BOM if present
                Some(cleaned.as_bytes().to_vec())
            } else {
                None
            }
        }
        
        /// Get all assets as JSON-formatted bytes
        pub fn get_all_assets_as_json_bytes() -> Vec<u8> {
            let assets = Self::get_all_assets();
            
            // If no assets, return empty array
            if assets.is_empty() {
                return "[]".as_bytes().to_vec();
            }
            
            // Format each asset as JSON
            let mut json_assets = Vec::new();
            for (_, asset) in assets {
                json_assets.push(Self::format_asset_as_json(&asset));
            }
            
            // Combine into a JSON array
            let json_array = format!("[{}]", json_assets.join(","));
            
            // Remove any stray non-printable characters
            let cleaned = json_array.trim_start_matches('\u{feff}');
            cleaned.as_bytes().to_vec()
        }

        /// Get all assets from storage
        pub fn get_all_assets() -> Vec<(u32, Asset<T::AccountId>)> {
            Assets::<T>::iter().collect()
        }

        /// Get a specific asset by ID
        pub fn get_asset(asset_id: u32) -> Option<Asset<T::AccountId>> {
            Assets::<T>::get(asset_id)
        }

        /// Get all scores for an asset
        pub fn get_asset_scores(asset_id: u32) -> Option<Vec<ScoreEntry>> {
            if let Some(scores) = AssetScores::<T>::get(asset_id) {
                Some(scores.0.into_inner().into_iter().collect())
            } else {
                None
            }
        }

        pub fn say_hello() -> Vec<u8> {
            "Hi from Risk Ratings Pallet!".as_bytes().to_vec()
        }
    }
}
