use anyhow::Result;
use arrow::array::{ArrayRef, Float64Array, Int32Array, StringArray};
use arrow::datatypes::{DataType, Field, Schema};
use arrow::record_batch::RecordBatch;
use async_trait::async_trait;
use chrono::NaiveDate;
use duckdb::Connection;
use std::sync::{Arc, Mutex};

use super::DataSource;

pub struct DuckDBDataSource {
	conn: Arc<Mutex<Connection>>,
}

impl DuckDBDataSource {
	pub fn new(db_path: &str) -> Result<Self> {
		let conn = Connection::open(db_path)?;
		Ok(Self { conn: Arc::new(Mutex::new(conn)) })
	}
}

#[async_trait]
impl DataSource for DuckDBDataSource {
	async fn get_time_vec(&self, _asset_id: i64) -> Result<Vec<NaiveDate>> {
		// Use from_ymd_opt and handle the Option
		Ok(vec![NaiveDate::from_ymd_opt(2022, 1, 1).expect("Invalid date")])
	}

	async fn get_ledger(&self, _asset_id: i64, _date: NaiveDate) -> Result<RecordBatch> {
		// Create a hardcoded record batch
		let schema = Arc::new(Schema::new(vec![
			Field::new("id", DataType::Int32, false),
			Field::new("name", DataType::Utf8, false),
			Field::new("balance", DataType::Float64, false),
			// Field::new("wallet_address", DataType::Utf8, false),
			// Field::new("new_txs", DataType::Boolean, false),
			// Field::new("total_balance", DataType::Float64, false),
			// Field::new("total_count", DataType::UInt64, false),
			// Field::new("tx_ratio", DataType::Float64, false),
		]));

		let batch = RecordBatch::try_new(
			schema,
			vec![
				Arc::new(Int32Array::from(vec![1, 2, 3])) as ArrayRef,
				Arc::new(StringArray::from(vec!["Alice", "Bob", "Charlie"])) as ArrayRef,
				Arc::new(Float64Array::from(vec![100.0, 200.0, 300.0])) as ArrayRef,
			],
		)?;
		Ok(batch)
	}

	async fn get_relation_network(&self, _asset_id: i64, _date: NaiveDate) -> Result<RecordBatch> {
		// Create a hardcoded record batch
		let schema = Arc::new(Schema::new(vec![
			Field::new("source", DataType::Int32, false),
			Field::new("target", DataType::Int32, false),
			Field::new("weight", DataType::Float64, false),
		]));

		let batch = RecordBatch::try_new(
			schema,
			vec![
				Arc::new(Int32Array::from(vec![1, 2, 3])) as ArrayRef,
				Arc::new(Int32Array::from(vec![2, 3, 1])) as ArrayRef,
				Arc::new(Float64Array::from(vec![10.0, 20.0, 30.0])) as ArrayRef,
			],
		)?;
		Ok(batch)
	}
}
