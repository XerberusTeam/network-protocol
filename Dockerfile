FROM rust:1.80.1-bookworm as builder

ENV RUST_BACKTRACE 1
ENV PROTOC=/usr/bin/protoc

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	build-essential \
	clang \
	libclang-dev \
	libssl-dev \
	protobuf-compiler \
	ca-certificates && \
	apt-get autoremove -y && \
	apt-get clean && \
	find /var/lib/apt/lists/ -type f -not -name lock -delete;

WORKDIR /usr/src

ADD ./model_runtime/ ./model_runtime/
ADD ./node/ ./node/
ADD ./pallets/ ./pallets/
ADD ./runtime/ ./runtime/
ADD ./Cargo.toml ./Cargo.toml
ADD ./Cargo.lock ./Cargo.lock
ADD ./rust-toolchain.toml ./rust-toolchain.toml
ADD ./rustfmt.toml ./rustfmt.toml

RUN cargo build --release

ADD ./chain-spec.json ./chain-spec.json

# Runtime stage
FROM debian:bookworm-slim

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
	libssl3 \
	ca-certificates && \
	apt-get autoremove -y && \
	apt-get clean && \
	find /var/lib/apt/lists/ -type f -not -name lock -delete;

# add user and link ~/.local/share/polkadot to /data
RUN  useradd -m -u 1000 -U -s /bin/sh -d /polkadot polkadot && \
	mkdir -p /data /polkadot/.local/share && \
	chown -R polkadot:polkadot /data && \
	ln -s /data /polkadot/.local/share/xerberus-net

USER polkadot

# copy the compiled binary to the container
COPY --chown=polkadot:polkadot --chmod=774 --from=builder /usr/src/target/release/ /usr/bin/
COPY --chown=polkadot:polkadot --chmod=774 --from=builder /usr/src/chain-spec.json /data/chain-spec.json

# check if executable works in this container
RUN /usr/bin/xerberus-net --version

# ws_port
EXPOSE 9930 9333 9944 30333 30334

ENTRYPOINT ["/usr/bin/xerberus-net"]
