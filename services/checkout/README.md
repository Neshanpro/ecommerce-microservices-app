# Checkout Service

The Checkout Service is a Go-based gRPC microservice responsible for orchestrating the overall order placement pipeline, checking out user carts, and communicating across all companion downstream services.

## 🛠 Features & Architecture Updates
* **Statically Linked Binary**: Built with strict optimization tags (`-trimpath -ldflags="-s -w"`) to drop debugger information and minimize size.
* **Distroless Static Runtime**: Upgraded from standard Linux distributions to Google's Distroless Static layer containing zero background binaries or shells.
* **Isolated Verification**: Engineered environment controls to disable the OpenTelemetry telemetry loop for isolated node validation.

---

## 🐳 Docker Deployment & Optimization Comparison

### 1. Build Instructions
Because this Go application references files out of the repository's shared `pb/` folder, the image compilation step must be executed from the root context directory structure:

```bash
# Move to the repository root directory
cd /home/ubuntu/projects/ecommerce-microservices-app

# Build the Single-Stage evaluation target
docker build -f services/checkout/Dockerfile.initial -t checkout-service:single-stage .

# Build the Production Multi-Stage evaluation target
docker build -f services/checkout/Dockerfile -t checkout-service:multi-stage .
```

### 2. Isolated Smoke Testing (With Mock Backends & Disabled Telemetry)
The service core checks for mandatory environmental microservice paths at startup. To run this container in complete isolation without crashing, pass **mock endpoints** and deactivate the OpenTelemetry collector lookups (`OTEL_SDK_DISABLED=true`):

```bash
# Remove stale container instances
docker rm -f checkout-smoke-test 2>/dev/null

# Spin up the container with required environment matrices
docker run -d \
  --name checkout-smoke-test \
  -p 5050:5050 \
  -e CHECKOUT_PORT=5050 \
  -e SHIPPING_ADDR="localhost:50050" \
  -e PRODUCT_CATALOG_ADDR="localhost:50051" \
  -e CART_ADDR="localhost:50052" \
  -e CURRENCY_ADDR="localhost:50053" \
  -e EMAIL_ADDR="localhost:50054" \
  -e PAYMENT_ADDR="localhost:50055" \
  -e OTEL_SDK_DISABLED="true" \
  checkout-service:multi-stage
```

### 3. Verification
Verify the gRPC loop started up correctly via the runtime daemon logging pipeline:

```bash
docker logs checkout-smoke-test
```
*Expected log output snippet:* `{"message":"starting to listen on tcp: \"[::]:5050\"","severity":"info"}`

### 📊 Container Size Metrics Comparison

| Architecture Strategy | Base Image Runtime | Security Profile | Final Image Size |
| :--- | :--- | :--- | :--- |
| **Single-Stage (Initial)** | `golang:1.22-alpine` | High Attack Surface (Contains entire Go SDK toolsets & build caches) | **~1.34 GB** |
| **Multi-Stage (Optimized)** | `gcr.io/distroless/static` | Enterprise Hardened (Zero shell systems, Runs purely the Go binary) | **~37.2 MB** |
<img width="1723" height="42" alt="Screenshot 2026-07-28 161651" src="https://github.com/user-attachments/assets/1cb2739e-6074-48bc-b01c-75a0102d17e5" />










