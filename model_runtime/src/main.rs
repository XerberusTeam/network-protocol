mod datasource;
mod datastore;
mod models;

use anyhow::Result;
use chrono::{NaiveDate, NaiveDateTime};
use datasource::DataSource;
use datastore::{Datastore, DuckDBStorage};
use models::{EmissionsModel, LedgerModel, NetworkModel};
use polars::prelude::*;

#[tokio::main]
async fn main() -> Result<()> {
	let asset_id = 26;
	let ledger_model = LedgerModel::new();
	let network_model = NetworkModel::new();
	let emissions_model = EmissionsModel::new(0.01);
	let duck_data = DuckDBStorage::new("xerberus.db")?;

	let dates = duck_data.get_time_vec(asset_id).await?;

	for date in dates {
		let ledger = duck_data.get_ledger(asset_id, date).await?;

		duck_data.save(ledger).await?;

		// let processed_ledger = ledger_model.process(ledger).await?;

		// let relation_network = duck_data.get_relation_network(asset_id, date).await?;
		// let processed_network = network_model.process(relation_network).await?;

		// let emissions = emissions_model.process(processed_ledger).await?;

		// storage.save(emissions).await?;
	}

	let dates: Vec<NaiveDateTime> = vec![
		NaiveDate::from_ymd_opt(2025, 1, 1).unwrap().and_hms_opt(0, 0, 0).unwrap(),
		NaiveDate::from_ymd_opt(2025, 1, 2).unwrap().and_hms_opt(0, 0, 0).unwrap(),
		NaiveDate::from_ymd_opt(2025, 1, 3).unwrap().and_hms_opt(0, 0, 0).unwrap(),
	];

	let df: DataFrame = df!(
		"integer" => &[1, 2, 3],
		"date" => &dates,
		"float" => &[4.0, 5.0, 6.0],
		"string" => &["a", "b", "c"],
	)?;

	println!("{}", df);

	Ok(())
}
