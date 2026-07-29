# Checkout Service

The Checkout Service is a Go-based gRPC microservice responsible for orchestrating the overall order placement pipeline, checking out user carts, and communicating across all companion downstream services.

## 🛠 Features & Architecture Updates

- **Statically Linked Binary**: Built with strict optimization tags (`-trimpath -ldflags="-s -w"`) to drop debugger information and minimize size.
- **Distroless Static Runtime**: Upgraded from standard Linux distributions to Google's Distroless Static layer containing zero background binaries or shells.
- **Non-Root Security**: Runs as UID 65532 (non-root user) for enhanced security.

## 🐳 Docker Deployment & Optimization Comparison

### Build Instructions

Because this Go application references files in the repository's shared `pb/` folder, the image build must execute from the repository root:

```bash
cd <repo-root>

# Build the Single-Stage baseline (for size comparison)
docker build -f services/checkout/Dockerfile.initial -t checkout:initial .

# Build the Production Multi-Stage optimized version
docker build -f services/checkout/Dockerfile -t checkout:optimized .
```

### Isolated Smoke Testing

The Checkout Service is an orchestrator that requires downstream service addresses at startup. For smoke testing with mock backends, run the optimized container with the required environment variables:

```bash
docker run -d \
  --name checkout-test \
  -p 5050:5050 \
  -e CHECKOUT_PORT=5050 \
  -e SHIPPING_ADDR=localhost:50050 \
  -e PRODUCT_CATALOG_ADDR=localhost:3550 \
  -e CART_ADDR=localhost:7070 \
  -e CURRENCY_ADDR=localhost:7000 \
  -e EMAIL_ADDR=localhost:8080 \
  -e PAYMENT_ADDR=localhost:50051 \
  -e FLAGD_ADDR=localhost:8013 \
  checkout:optimized
```
  
### Environment Variables

| Variable | Required | Default | Description |
| :--- | :--- | :--- | :--- |
| **CHECKOUT_PORT** | Yes | — | Port for gRPC server to listen on |
| **SHIPPING_ADDR** | Yes | — | Address of Shipping service |
| **PRODUCT_CATALOG_ADDR** | Yes | — | Address of Product Catalog service |
| **CART_ADDR** | Yes | — | Address of Cart service |
| **CURRENCY_ADDR** | Yes | — | Address of Currency service |
| **EMAIL_ADDR** | Yes | — | Address of Email service |
| **PAYMENT_ADDR** | Yes | — | Address of Payment service |
| **FLAGD_ADDR** | No | localhost:8013 | Address of Feature Flag service |

### Verification

Check the logs to confirm the gRPC server started:
```bash
docker logs checkout-test
```

Expected output:
```json
{"message":"starting to listen on tcp: \"[::]:5050\"","severity":"info"}
```

Test the gRPC connection:
```bash
curl -v localhost:5050
```
*Expected: Connection established (HTTP/0.9 error is normal for gRPC over HTTP/1.1).*

### Teardown

```bash
docker stop checkout-test
docker rm checkout-test
```

## 📊 Container Size Metrics Comparison

| Strategy | Base Image | Security Profile | Final Size |
| :--- | :--- | :--- | :--- |
| **Single-Stage (Initial)** | `golang:1.22-alpine` | High attack surface (full Go SDK + build tools) | 1.34 GB |
| **Multi-Stage (Optimized)** | `gcr.io/distroless/static-debian12` | Enterprise hardened (zero shell, non-root) | 37.2 MB |

<img width="1762" height="46" alt="Screenshot 2026-07-29 044641" src="https://github.com/user-attachments/assets/dbe68cdf-fe7f-4e4d-ab13-f1b7fd7de683" />

**Savings:** 97.2% size reduction ✅
