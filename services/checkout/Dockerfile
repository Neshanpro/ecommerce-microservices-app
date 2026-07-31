# --- STAGE 1: Builder ---
FROM golang:1.22-alpine AS builder

# Replicate the repository structure root inside the container
WORKDIR /usr/src

# Copy checkout dependency manifests into their expected subdirectory structure
COPY ./services/checkout/go.mod ./services/checkout/go.sum ./services/checkout/
RUN cd services/checkout && go mod download

# Copy the shared protocol buffers (pb) folder natively into /usr/src/pb
COPY ./pb/ ./pb/

# Copy the remaining checkout source code into its matching subdirectory
COPY ./services/checkout/ ./services/checkout/

# Pivot workspace into the service folder to compile cleanly
WORKDIR /usr/src/services/checkout
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/checkout .

# --- STAGE 2: Secure Distroless Runtime ---
FROM gcr.io/distroless/static-debian12

WORKDIR /usr/src/app

# Copy the compiled binary from the builder stage
COPY --from=builder /out/checkout ./checkout

# Run as non-root user
USER 65532

ENV CHECKOUT_PORT=5050
EXPOSE 5050

ENTRYPOINT ["./checkout"]

