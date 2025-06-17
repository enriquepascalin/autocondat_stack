# Stage 1: build
FROM rust:1.79-slim-bookworm AS builder
WORKDIR /app
# Create a dummy project to leverage cached dependencies
RUN USER=root cargo new autocondat_actix
WORKDIR /app/autocondat_actix
COPY Cargo.toml .
RUN cargo fetch
# Copy real source and build in release mode
COPY . .
RUN cargo build --release

# Stage 2: runtime image
FROM gcr.io/distroless/cc
WORKDIR /app
COPY --from=builder /app/autocondat_actix/target/release/autocondat_actix .
EXPOSE 8080
ENTRYPOINT ["./autocondat_actix"]

