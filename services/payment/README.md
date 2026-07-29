# Payment Service

The Payment Service is a high-performance gRPC microservice responsible for processing, charging, and validating user payments across the application ecosystem.

## 🛠 Features & Architecture Updates

- **gRPC Interface**: High-performance remote procedure calls using Protocol Buffers.
- **Production Hardened**: Multi-stage Docker build with enterprise-grade Google Distroless runtime.
- **Non-Root Security**: Runs as UID 10001 (non-root user).
- **Telemetry Ready**: Native OpenTelemetry instrumentation for tracing and metrics.

## 💻 Local Development

To run this microservice locally outside containers:

```bash
cd services/payment

# Copy the shared proto file
cp ../../pb/demo.proto ./

# Install dependencies
npm ci

# Start the service
PAYMENT_PORT=50051 node index.js
```

## 🐳 Docker Deployment & Optimization Comparison

### Build Instructions

The service relies on the shared `pb/` directory, so build from repository root:

```bash
cd <repo-root>

# Build the Single-Stage baseline (for size comparison)
docker build -f services/payment/Dockerfile.initial -t payment:initial .

# Build the Production Multi-Stage optimized version
docker build -f services/payment/Dockerfile -t payment:optimized .
```

### Isolated Smoke Testing

```bash
# Run the optimized container
docker run -d \
  --name payment-test \
  -p 50051:50051 \
  -e PAYMENT_PORT=50051 \
  payment:optimized
```

### Environment Variables

| Variable | Required | Default | Description |
| :--- | :--- | :--- | :--- |
| **PAYMENT_PORT** | Yes | — | Port for gRPC server to listen on |

### Verification

Check the logs:
```bash
docker logs payment-test
```

Expected output:
```json
{"level":"info","msg":"payment gRPC server started on port 50051"}
```

Test the gRPC connection:
```bash
curl -v localhost:50051
```
*Expected: Connection established.*

Or with `grpcurl`:
```bash
grpcurl -plaintext localhost:50051 list
```
*Expected: Lists available gRPC services (e.g., oteldemo.PaymentService).*

### Teardown

```bash
docker stop payment-test
docker rm payment-test
```

## 📊 Container Size Metrics Comparison

| Strategy | Base Image | Security Profile | Final Size |
| :--- | :--- | :--- | :--- |
| **Single-Stage (Initial)** | `node:20 (Debian)` | High attack surface (includes bash, apt, curl) | 1.71 GB |
| **Multi-Stage (Optimized)** | `gcr.io/distroless/nodejs20-debian12` | Enterprise hardened (zero shell, non-root) | 265 MB |

<img width="1797" height="42" alt="Screenshot 2026-07-29 041845" src="https://github.com" />

**Savings:** 84.5% size reduction ✅
