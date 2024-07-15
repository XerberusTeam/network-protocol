use anyhow::Result;
use arrow::record_batch::RecordBatch;
use async_trait::async_trait;

#[async_trait]
pub trait Model {
	async fn process(&self, input: RecordBatch) -> Result<RecordBatch>;
}

pub mod emissions;
pub mod ledger;
pub mod network;

pub use emissions::EmissionsModel;
pub use ledger::LedgerModel;
pub use network::NetworkModel;
