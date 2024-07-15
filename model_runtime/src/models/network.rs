use super::Model;
use anyhow::Result;
use arrow::array::{Array, Float64Array, StringArray};
use arrow::datatypes::{DataType, Field, Schema};
use arrow::record_batch::RecordBatch;
use async_trait::async_trait;
use std::sync::Arc;

pub struct NetworkModel;

impl NetworkModel {
	pub fn new() -> Self {
		Self
	}
}

#[async_trait]
impl Model for NetworkModel {
	async fn process(&self, input: RecordBatch) -> Result<RecordBatch> {
		let source = input
			.column_by_name("source")
			.unwrap()
			.as_any()
			.downcast_ref::<StringArray>()
			.unwrap();
		let amount = input
			.column_by_name("amount")
			.unwrap()
			.as_any()
			.downcast_ref::<Float64Array>()
			.unwrap();
		let target = input
			.column_by_name("target")
			.unwrap()
			.as_any()
			.downcast_ref::<StringArray>()
			.unwrap();

		let schema = Schema::new(vec![
			Field::new("source", DataType::Utf8, false),
			Field::new("amount", DataType::Float64, false),
			Field::new("target", DataType::Utf8, false),
		]);

		let processed_batch = RecordBatch::try_new(
			Arc::new(schema),
			vec![Arc::new(source.clone()), Arc::new(amount.clone()), Arc::new(target.clone())],
		)?;

		Ok(processed_batch)
	}
}
