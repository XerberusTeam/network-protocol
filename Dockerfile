FROM docker.io/paritytech/ci-unified:latest as builder

WORKDIR /polkadot
COPY . /polkadot

RUN cargo fetch
RUN cargo build --locked --release

FROM docker.io/parity/base-bin:latest

COPY --from=builder /polkadot/target/release/solochain-template-node /usr/local/bin

USER root
RUN useradd -m -u 1001 -U -s /bin/sh -d /polkadot polkadot && \
	mkdir -p /data /polkadot/.local/share && \
	chown -R polkadot:polkadot /data && \
	ln -s /data /polkadot/.local/share/polkadot && \
# unclutter and minimize the attack surface
	rm -rf /usr/bin /usr/sbin

# Copy the chain spec file after creating the user
COPY --chown=polkadot:polkadot --chmod=774 chain-spec-raw.json /data/chain-spec-raw.json

USER polkadot

EXPOSE 30333 9933 9944 9615
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/solochain-template-node"]
