//! # Risk Ratings Pallet
//!
//! A FRAME pallet for managing partition-based risk scores.

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

    /// Single risk score entry
    #[derive(Clone, Encode, Decode, PartialEq, Eq, RuntimeDebug, TypeInfo, MaxEncodedLen)]
    pub struct ScoreEntry {
        pub score: u32,
        pub timestamp: u32,
    }

    /// Vector of score entries for a partition
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
        ScoreUpdated {
            partition: BoundedVec<u8, ConstU32<100>>,
            score: u32,
            timestamp: u32,
            updater: T::AccountId,
        },
    }

    #[pallet::error]
    pub enum Error<T> {
        MaxScoresReached,
        PartitionTooLong,
    }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        #[pallet::call_index(0)]
        #[pallet::weight(T::WeightInfo::update_score())]
        pub fn update_score(
            origin: OriginFor<T>,
            partition: Vec<u8>,
            score: u32,
            timestamp: u32,
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
        pub fn say_hello() -> Vec<u8> {
            "Hello from Risk Ratings Pallet!".as_bytes().to_vec()
        }

        /// Get scores for the specified partition if it exists in storage,
        /// otherwise return dummy data for testing RPC functionality
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
                    // No data found for this partition - return empty list
                    Vec::new()
                }
            }
        }
    }
}
