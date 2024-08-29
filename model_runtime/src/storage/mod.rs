use anyhow::Result;
use arrow::record_batch::RecordBatch;
use async_trait::async_trait;

#[async_trait]
pub trait Storage {
	async fn save(&self, data: RecordBatch) -> Result<()>;
}

pub mod duckdb;

pub use duckdb::DuckDBStorage;
