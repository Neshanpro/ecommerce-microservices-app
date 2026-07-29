# Recommendation Service

The Recommendation Service is a Python-based gRPC microservice that generates personalized product recommendations by querying the Product Catalog service.

## 🛠 Features & Architecture Updates

- **gRPC Interface**: High-performance remote procedure calls using Protocol Buffers.
- **OpenTelemetry Instrumentation**: Zero-code auto-instrumentation for tracing and observability.
- **Multi-Stage Build**: Optimized Python packaging to minimize final image size.
- **Production Ready**: Configured with structured JSON logging and proper signal handling.

## 💻 Local Development

To run this microservice locally:

```bash
cd src/recommendation

# Create virtual environment
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows

# Install dependencies
pip install -r requirements.txt

# Start the service
RECOMMENDATION_PORT=9001 \
PRODUCT_CATALOG_ADDR=localhost:3550 \
OTEL_SERVICE_NAME=recommendation \
python recommendation_server.py
```

## 🐳 Docker Deployment & Optimization Comparison

### Build Instructions

The service can be built from the repository root or service directory:

```bash
# Option 1: From repository root (if using shared pb/ files)
cd <repo-root>
docker build -f src/recommendation/Dockerfile.initial -t recommendation:initial .
docker build -f src/recommendation/Dockerfile -t recommendation:optimized .

# Option 2: From service directory
cd src/recommendation
docker build -f Dockerfile.initial -t recommendation:initial .
docker build -f Dockerfile -t recommendation:optimized .
```

### Isolated Smoke Testing

```bash
# Run the optimized container
docker run -d \
  --name reco-test \
  -p 9001:9001 \
  -e OTEL_SERVICE_NAME=recommendation \
  -e RECOMMENDATION_PORT=9001 \
  -e PRODUCT_CATALOG_ADDR=localhost:3550 \
  recommendation:optimized
```

### Environment Variables

| Variable | Required | Default | Description |
| :--- | :--- | :--- | :--- |
| **RECOMMENDATION_PORT** | Yes | — | Port for gRPC server to listen on |
| **OTEL_SERVICE_NAME** | Yes | — | Service name for OpenTelemetry traces |
| **PRODUCT_CATALOG_ADDR** | Yes | — | Address of Product Catalog service (e.g., localhost:3550) |

### Verification

Check the logs:
```bash
docker logs reco-test
```

Expected output:
```json
{"level":"info","msg":"Recommendation server started, listening on port 9001"}
```

Test the gRPC connection:
```bash
curl -v localhost:9001
```
*Expected: Connection established (HTTP/0.9 error is normal for gRPC over HTTP/1.1).*

Or with `grpcurl`:
```bash
grpcurl -plaintext localhost:9001 list
```
*Expected: Lists available gRPC services (e.g., oteldemo.RecommendationService).*

### Teardown

```bash
docker stop reco-test
docker rm reco-test
```

## 📊 Container Size Metrics Comparison

| Strategy | Base Image | Security Profile | Final Size |
| :--- | :--- | :--- | :--- |
| **Single-Stage (Initial)** | `python:3.12-slim-bookworm` | Standard (includes pip, build tools) | 276 MB |
| **Multi-Stage (Optimized)** | `python:3.12-slim-bookworm` (builder) + runtime | Minimal runtime (removes build artifacts) | 238 MB |

<img width="1721" height="85" alt="Screenshot 2026-07-29 040049" src="https://github.com/user-attachments/assets/48f56fb0-2bfb-4cc3-871c-801acc791e8a" />

**Savings:** 13.8% size reduction ✅

## 🔧 Troubleshooting

### ModuleNotFoundError: No module named 'grpc'
* Ensure `requirements.txt` is properly copied and installed in the Dockerfile.
* Verify `PYTHONPATH` is set correctly if you are copying dependencies to a custom directory in a multi-stage build.

### OTEL_SERVICE_NAME environment variable must be set
* Always pass `-e OTEL_SERVICE_NAME=recommendation` when running the container to avoid telemetry initialization errors.

### PRODUCT_CATALOG_ADDR environment variable must be set
* Always pass `-e PRODUCT_CATALOG_ADDR=<address>` when running the container so the service can fetch products.

### Connection refused on port 9001
* Check that the container is still running:
  ```bash
  docker ps | grep reco
  ```
* View logs for application startup or configuration errors:
  ```bash
  docker logs reco-test
  ```
