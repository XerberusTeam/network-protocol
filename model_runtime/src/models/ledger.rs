use async_trait::async_trait;
use anyhow::Result;
use arrow::record_batch::RecordBatch;
use arrow::array::{Array, Float64Array, UInt64Array, BooleanArray, StringArray};
use arrow::datatypes::{Schema, Field, DataType};
use std::sync::Arc;
use super::Model;

pub struct LedgerModel;

impl LedgerModel {
    pub fn new() -> Self {
        Self
    }
}

#[async_trait]
impl Model for LedgerModel {
    async fn process(&self, input: RecordBatch) -> Result<RecordBatch> {
        let wallet_address = input.column_by_name("wallet_address").unwrap().as_any().downcast_ref::<StringArray>().unwrap();
        let new_txs = input.column_by_name("new_txs").unwrap().as_any().downcast_ref::<BooleanArray>().unwrap();
        let total_balance = input.column_by_name("total_balance").unwrap().as_any().downcast_ref::<Float64Array>().unwrap();
        let total_count = input.column_by_name("total_count").unwrap().as_any().downcast_ref::<UInt64Array>().unwrap();
        let tx_ratio = input.column_by_name("tx_ratio").unwrap().as_any().downcast_ref::<Float64Array>().unwrap();

        let schema = Schema::new(vec![
            Field::new("wallet_address", DataType::Utf8, false),
            Field::new("new_txs", DataType::Boolean, false),
            Field::new("total_balance", DataType::Float64, false),
            Field::new("total_count", DataType::UInt64, false),
            Field::new("tx_ratio", DataType::Float64, false),
        ]);

        let processed_batch = RecordBatch::try_new(
            Arc::new(schema),
            vec![
                Arc::new(wallet_address.clone()),
                Arc::new(new_txs.clone()),
                Arc::new(total_balance.clone()),
                Arc::new(total_count.clone()),
                Arc::new(tx_ratio.clone()),
            ],
        )?;

        Ok(processed_batch)
    }
}
