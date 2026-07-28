# --- STAGE 1: Builder ---
FROM golang:1.22-alpine AS builder

WORKDIR /usr/src/app

# Copy dependency manifests
COPY ./services/checkout/go.mod ./services/checkout/go.sum ./
RUN go mod download

# Copy the checkout service code and the shared pb folder natively
COPY ./services/checkout/ ./
COPY ./pb/ ./pb/

# Compile the production binary cleanly
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

