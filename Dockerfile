FROM rust as chef
WORKDIR /app
RUN apt update && apt install lld clang -y
RUN cargo install cargo-chef

FROM chef as planner
COPY . .
RUN cargo chef prepare  --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --bin rust-docker-demo

FROM debian:bullseye-slim AS runtime
WORKDIR /app
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends openssl ca-certificates \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/rust-docker-demo rust-docker-demo
COPY --from=builder /app/resources resources

ENV APP_ENVIRONMENT production
ENTRYPOINT ["./rust-docker-demo"]

## NOTE: Do not forget to put target in .dockerignore to avoid recompilation
