use super::Storage;
use anyhow::{Context, Result};
use arrow::record_batch::RecordBatch;
use async_trait::async_trait;
use duckdb::{params, Connection};
use std::sync::{Arc, Mutex};
use tokio::task;

pub struct DuckDBStorage {
	conn: Arc<Mutex<Connection>>,
}

impl DuckDBStorage {
	pub fn new(db_path: &str) -> Result<Self> {
		let conn = Connection::open(db_path).context("Failed to open DuckDB connection")?;

		// Create the table if it doesn't exist
		conn.execute_batch(
			"
            CREATE TABLE IF NOT EXISTS emissions (
                wallet_address VARCHAR,
                dilution DOUBLE,
                total_balance DOUBLE,
                total_count INTEGER,
                tx_ratio DOUBLE,
                last_seen DATE
            )
            ",
		)
		.context("Failed to create emissions table")?;

		Ok(Self { conn: Arc::new(Mutex::new(conn)) })
	}
}

#[async_trait]
impl Storage for DuckDBStorage {
	async fn save(&self, data: RecordBatch) -> Result<()> {
		let conn = Arc::clone(&self.conn);

		// Offload blocking I/O to a blocking thread.
		task::spawn_blocking(move || {
            let mut conn = conn.lock().unwrap();
            let transaction = conn.transaction().context("Failed to start transaction")?;

            let wallet_addresses =
                data.column(0).as_any().downcast_ref::<arrow::array::StringArray>().unwrap();
            let dilutions =
                data.column(1).as_any().downcast_ref::<arrow::array::Float64Array>().unwrap();
            let total_balances =
                data.column(2).as_any().downcast_ref::<arrow::array::Float64Array>().unwrap();
            let total_counts =
                data.column(3).as_any().downcast_ref::<arrow::array::Int64Array>().unwrap();
            let tx_ratios =
                data.column(4).as_any().downcast_ref::<arrow::array::Float64Array>().unwrap();
            let last_seens =
                data.column(5).as_any().downcast_ref::<arrow::array::Date32Array>().unwrap();

            let mut stmt = transaction.prepare(
                "
                INSERT INTO emissions (wallet_address, dilution, total_balance, total_count, tx_ratio, last_seen)
                VALUES (?, ?, ?, ?, ?, ?)
                ",
            )?;

            for i in 0..data.num_rows() {
                stmt.execute(params![
                    wallet_addresses.value(i),
                    dilutions.value(i),
                    total_balances.value(i),
                    total_counts.value(i),
                    tx_ratios.value(i),
                    last_seens.value(i), // DuckDB expects dates as integers (days since epoch)
                ])
                .context("Failed to insert row into emissions table")?;
            }

            transaction.commit().context("Failed to commit transaction")?;
            Result::<(), anyhow::Error>::Ok(())
        })
        .await
        .context("Failed to save data")??;

		Ok(())
	}
}
