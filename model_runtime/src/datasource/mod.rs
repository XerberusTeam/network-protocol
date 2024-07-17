use anyhow::Result;
use arrow::record_batch::RecordBatch;
use async_trait::async_trait;

#[async_trait]
pub trait DataSource {
	async fn get_time_vec(&self, asset_id: i64) -> Result<Vec<chrono::NaiveDate>>;
	async fn get_ledger(&self, asset_id: i64, date: chrono::NaiveDate) -> Result<RecordBatch>;
	async fn get_relation_network(
		&self,
		asset_id: i64,
		date: chrono::NaiveDate,
	) -> Result<RecordBatch>;
}
