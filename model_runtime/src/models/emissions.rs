use super::Model;
use anyhow::Result;
use arrow::array::{Array, BooleanArray, Float64Array, StringArray, UInt64Array};
use arrow::datatypes::{DataType, Field, Schema};
use arrow::record_batch::RecordBatch;
use async_trait::async_trait;
use std::collections::{HashMap, VecDeque};
use std::sync::Arc;

pub struct EmissionsModel {
	threshold: f64,
}

impl EmissionsModel {
	pub fn new(threshold: f64) -> Self {
		Self { threshold }
	}

	fn emissions_bfs(&self, network: &RecordBatch, wallet: &str) -> HashMap<String, f64> {
		let mut visited = std::collections::HashSet::new();
		let mut queue = VecDeque::new();
		queue.push_back((wallet.to_string(), 0, 1.0));
		visited.insert(wallet.to_string());
		let mut node_cumulative_dilution = HashMap::new();

		let source_array = network
			.column_by_name("source")
			.unwrap()
			.as_any()
			.downcast_ref::<StringArray>()
			.unwrap();
		let amount_array = network
			.column_by_name("amount")
			.unwrap()
			.as_any()
			.downcast_ref::<Float64Array>()
			.unwrap();
		let target_array = network
			.column_by_name("target")
			.unwrap()
			.as_any()
			.downcast_ref::<StringArray>()
			.unwrap();

		while let Some((current_node, current_depth, dilution)) = queue.pop_front() {
			for i in 0..network.num_rows() {
				if target_array.value(i) == current_node {
					let new_dilution = dilution * amount_array.value(i);
					if new_dilution < self.threshold {
						continue;
					}

					let source = source_array.value(i).to_string();
					*node_cumulative_dilution.entry(source.clone()).or_insert(0.0) += new_dilution;

					if !visited.contains(&source) {
						visited.insert(source.clone());
						queue.push_back((source, current_depth + 1, new_dilution));
					}
				}
			}
		}

		node_cumulative_dilution
	}
}

#[async_trait]
impl Model for EmissionsModel {
	async fn process(&self, input: RecordBatch) -> Result<RecordBatch> {
		let wallet_address = input
			.column_by_name("wallet_address")
			.unwrap()
			.as_any()
			.downcast_ref::<StringArray>()
			.unwrap();
		let new_txs = input
			.column_by_name("new_txs")
			.unwrap()
			.as_any()
			.downcast_ref::<BooleanArray>()
			.unwrap();
		let total_balance = input
			.column_by_name("total_balance")
			.unwrap()
			.as_any()
			.downcast_ref::<Float64Array>()
			.unwrap();
		let total_count = input
			.column_by_name("total_count")
			.unwrap()
			.as_any()
			.downcast_ref::<UInt64Array>()
			.unwrap();
		let tx_ratio = input
			.column_by_name("tx_ratio")
			.unwrap()
			.as_any()
			.downcast_ref::<Float64Array>()
			.unwrap();

		let minting_wallet = "0x0000000000000000000000000000000000000000";
		let mut dilutions = Vec::new();

		for i in 0..input.num_rows() {
			if new_txs.value(i) {
				let node_dilute = self.emissions_bfs(&input, wallet_address.value(i));
				dilutions.push(*node_dilute.get(minting_wallet).unwrap_or(&0.0));
			} else {
				dilutions.push(0.0);
			}
		}

		let schema = Schema::new(vec![
			Field::new("wallet_address", DataType::Utf8, false),
			Field::new("dilution", DataType::Float64, false),
			Field::new("total_balance", DataType::Float64, false),
			Field::new("total_count", DataType::UInt64, false),
			Field::new("tx_ratio", DataType::Float64, false),
		]);

		let processed_batch = RecordBatch::try_new(
			Arc::new(schema),
			vec![
				Arc::new(wallet_address.clone()),
				Arc::new(Float64Array::from(dilutions)),
				Arc::new(total_balance.clone()),
				Arc::new(total_count.clone()),
				Arc::new(tx_ratio.clone()),
			],
		)?;

		Ok(processed_batch)
	}
}
