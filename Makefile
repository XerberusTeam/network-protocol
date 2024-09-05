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

build:
	./scripts/build.sh

publish:
	./scripts/publish.sh

# Build the chainspec file
build-new-spec:
	./scripts/xerberus-node.sh build-spec \
	--disable-default-bootnode > ./chain-spec.json
	cat ./chain-spec.json

build-spec:
	./scripts/xerberus-node.sh build-spec \
	--chain ./chain-spec.json \
	--raw > ./chain-spec-raw.json
	cat ./chain-spec.json

generate-node-key:
	./scripts/subkey.sh generate-node-key

generate-user-key:
	./scripts/subkey.sh generate

join-testnet:
	./scripts/join-testnet.sh