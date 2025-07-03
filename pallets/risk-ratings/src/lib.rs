//! # Risk Ratings Pallet
//!
//! A FRAME pallet for managing partition-based risk scores using deterministic fixed-point arithmetic.
//!
//! ## Why i128 Instead of Floating-Point?
//!
//! **Floating-point types (f32/f64) are incompatible with blockchain consensus:**
//! - Different CPUs produce different results (Intel vs AMD vs ARM) breaking consensus
//! - SCALE codec intentionally excludes floating-point to prevent non-deterministic serialization
//! - IEEE 754 rounding inconsistencies cause validator nodes to diverge
//!
//! **i128 is the industry standard across all blockchain ecosystems:**
//! - Substrate: pallet-balances, pallet-staking, pallet-democracy all use fixed-point types
//! - Ethereum: Uses uint256 scaled by 10^18 (wei) - no native floating-point
//! - DeFi: Uniswap, Compound, Aave all use fixed-point math for price/rate calculations
//! - Provides 18 decimal precision when scaled by 10^18, deterministic results, and SCALE codec support

#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

pub mod weights;
pub use weights::*;

pub mod runtime_api;

#[frame_support::pallet]
pub mod pallet {
    use super::*;
    use frame_support::pallet_prelude::*;
    use frame_system::pallet_prelude::*;
    use sp_std::prelude::*;
    // Using i128 instead of FixedI128 to avoid dependency issues
    // i128 provides 18 decimal precision when scaled by 10^18

    /// Single risk score entry using i128 for deterministic fixed-point arithmetic
    /// 
    /// **Why i128?** Floating-point types break blockchain consensus due to hardware-dependent
    /// results and SCALE codec incompatibility. i128 provides deterministic 18-decimal precision
    /// when scaled by 10^18, following the same pattern as pallet-balances, pallet-staking, and all major DeFi protocols.
    #[derive(Clone, Encode, Decode, PartialEq, Eq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct ScoreEntry {
        /// Risk score using deterministic i128 (18 decimal places when scaled by 10^18)
        /// Examples: "-8.5" → -8500000000000000000, "33333333" → 33333333000000000000000000
        pub score: i128,
        /// Unix timestamp in seconds (u64)
        pub timestamp: u64,
    }

    /// Vector of score entries for a partition (max 1000 entries)
    #[derive(Clone, Encode, Decode, PartialEq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct ScoreEntries(pub BoundedVec<ScoreEntry, ConstU32<1000>>);

    #[pallet::pallet]
    pub struct Pallet<T>(_);

    #[pallet::config]
    pub trait Config: frame_system::Config {
        type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
        type WeightInfo: WeightInfo;
    }

    #[pallet::storage]
    pub type PartitionScores<T> = StorageMap<
        _,
        Blake2_128Concat,
        BoundedVec<u8, ConstU32<100>>,
        ScoreEntries,
        OptionQuery
    >;

    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        /// Risk score updated for a partition
        ScoreUpdated {
            partition: BoundedVec<u8, ConstU32<100>>,
            score: i128,
            timestamp: u64,
            updater: T::AccountId,
        },
    }

    #[pallet::error]
    pub enum Error<T> {
        /// Maximum 1000 scores reached for this partition
        MaxScoresReached,
        /// Partition name exceeds 100 bytes
        PartitionTooLong,
    }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        /// Update risk score for a partition using i128 for deterministic consensus
        /// 
        /// **Client Usage:** `api.createType('i128', '-8500000000000000000')` - Polkadot.js handles conversion
        /// **Industry Standard:** Same pattern as pallet-balances, pallet-staking, Uniswap, Compound
        #[pallet::call_index(0)]
        #[pallet::weight(T::WeightInfo::update_score())]
        pub fn update_score(
            origin: OriginFor<T>,
            partition: Vec<u8>,
            score: i128,    // ✅ Substrate ecosystem standard
            timestamp: u64,
        ) -> DispatchResult {
            let who = ensure_signed(origin)?;

            // Convert to bounded vector
            let bounded_partition = BoundedVec::<u8, ConstU32<100>>::try_from(partition.clone())
                .map_err(|_| Error::<T>::PartitionTooLong)?;

            let score_entry = ScoreEntry {
                score,
                timestamp,
            };

            PartitionScores::<T>::try_mutate(&bounded_partition, |scores_opt| -> DispatchResult {
                match scores_opt {
                    Some(scores) => {
                        scores.0.try_push(score_entry.clone())
                            .map_err(|_| Error::<T>::MaxScoresReached)?;
                    },
                    None => {
                        let mut new_scores = BoundedVec::new();
                        new_scores.try_push(score_entry.clone())
                            .map_err(|_| Error::<T>::MaxScoresReached)?;
                        *scores_opt = Some(ScoreEntries(new_scores));
                    }
                }
                Ok(())
            })?;

            Self::deposit_event(Event::ScoreUpdated {
                partition: bounded_partition,
                score,
                timestamp,
                updater: who,
            });

            Ok(())
        }
    }

    impl<T: Config> Pallet<T> {
        /// Test method for runtime API integration
        pub fn say_hello() -> Vec<u8> {
            "Hello from Risk Ratings Pallet!".as_bytes().to_vec()
        }

        /// Get scores for the specified partition (returns empty vector if none exist)
        pub fn get_scores(partition: Vec<u8>) -> Vec<ScoreEntry> {
            // Convert partition to BoundedVec (same as in update_score extrinsic)
            let bounded_partition = match BoundedVec::<u8, ConstU32<100>>::try_from(partition) {
                Ok(bounded) => bounded,
                Err(_) => {
                    // Partition name too long - return empty list
                    return Vec::new();
                }
            };

            // Query storage for the specified partition
            match PartitionScores::<T>::get(&bounded_partition) {
                Some(score_entries) => {
                    // Found real data in storage - convert ScoreEntries to Vec<ScoreEntry>
                    score_entries.0.into_inner()
                },
                None => {
                    // No data found in storage - return empty vector
                    Vec::new()
                }
            }
        }
    }
}
