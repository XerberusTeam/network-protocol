.DEFAULT_GOAL=help

# Show this help.
help:
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:print:]]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t

# Run the example chain
run-temp:
	cargo run --release -- --dev --tmp

run-chain:
	cargo run --release -- --dev --ws-external --rpc-external

purge-chain:
	cargo run --release -- purge-chain --dev
