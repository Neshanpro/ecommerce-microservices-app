# Payment Service

The Payment Service is a high-performance gRPC microservice responsible for processing, charging, and validating user payments across the application ecosystem.

## 🛠 Features & Architecture Updates
* **gRPC Interface**: Communicates via high-performance remote procedure calls using Protocol Buffers.
* **Production Hardened**: Upgraded to a multi-stage Docker configuration using an enterprise-grade Google Distroless runtime.
* **Telemetry Ready**: Implements native OpenTelemetry hooks (`opentelemetry.js`) for tracing, logs, and metrics pipelines.

---

## 💻 Local Development

To run this microservice locally outside of a container environment, manually map the shared protocol buffer manifest:

```bash
# Navigate to the payment service directory
cd services/payment

# Copy the shared proto file locally
cp ../../pb/demo.proto ./

# Install exact version-locked dependencies
npm ci

# Start the application locally
PAYMENT_PORT=50051 node index.js
```

---

## 🐳 Docker Deployment & Optimization Comparison

This service features a highly optimized **Multi-Stage Build Pipeline** that drops unnecessary build utilities, shell components, and package managers to dramatically minimize attack surfaces and download sizes.

### 1. Build and Run via Docker Engine
Because this microservice relies on a shared `pb/` directory layout at the repository root, you must pass the **root context (`.`)** when building:

```bash
# Execute build from the repository root
docker build -f services/payment/Dockerfile -t payment-service:multi-stage.

# Run the container with necessary gRPC port mappings
docker run -d \
  --name payment-smoke-test \
  -p 50051:50051 \
  -e PORT=50051 \
  -e PAYMENT_PORT=50051 \
  payment-service:multi-stage
```

### 2. Build and Run via Compose (Recommended)
Alternatively, manage the runtime execution declaratively from the root using Docker Compose:

```bash
docker compose build payment
docker compose up -d payment
```

### 📊 Container Size Metrics Comparison

| Architecture Strategy | Base Image Runtime | Security Profile | Final Image Size |
# Payment Service

The Payment Service is a high-performance gRPC microservice responsible for processing, charging, and validating user payments across the application ecosystem.

## 🛠 Features & Architecture Updates
* **gRPC Interface**: Communicates via high-performance remote procedure calls using Protocol Buffers.
* **Production Hardened**: Upgraded to a multi-stage Docker configuration using an enterprise-grade Google Distroless runtime.
* **Telemetry Ready**: Implements native OpenTelemetry hooks (`opentelemetry.js`) for tracing, logs, and metrics pipelines.

---

## 💻 Local Development

To run this microservice locally outside of a container environment, manually map the shared protocol buffer manifest:

```bash
# Navigate to the payment service directory
cd services/payment

# Copy the shared proto file locally
cp ../../pb/demo.proto ./

# Install exact version-locked dependencies
npm ci

# Start the application locally
PAYMENT_PORT=50051 node index.js
```

---

## 🐳 Docker Deployment & Optimization Comparison

This service features a highly optimized **Multi-Stage Build Pipeline** that drops unnecessary build utilities, shell components, and package managers to dramatically minimize attack surfaces and download sizes.

### 1. Build and Run via Docker Engine
Because this microservice relies on a shared `pb/` directory layout at the repository root, you must pass the **root context (`.`)** when building:

```bash
# Execute build from the repository root
docker build -f services/payment/Dockerfile -t payment-service:multi-stage.

# Run the container with necessary gRPC port mappings
docker run -d \
  --name payment-smoke-test \
  -p 50051:50051 \
  -e PORT=50051 \
  -e PAYMENT_PORT=50051 \
  payment-service:multi-stage
```

### 2. Build and Run via Compose (Recommended)
Alternatively, manage the runtime execution declaratively from the root using Docker Compose:

```bash
docker compose build payment
docker compose up -d payment
```

### 📊 Container Size Metrics Comparison

| Architecture Strategy | Base Image Runtime | Security Profile | Final Image Size |
| :--- | :--- | :--- | :--- |
| **Single-Stage (Initial)** | `node:20` (Debian Full) | High Attack Surface (Contains curl, apt, bash, root tools) | **~1.77 GB** |
| **Multi-Stage (Optimized)** | `gcr.io/distroless/nodejs20` | Enterprise Hardened (Zero shell utilities, Non-root UID) | **~265 MB** |
<img width="1712" height="67" alt="Screenshot 2026-07-28 142532" src="https://github.com/user-attachments/assets/2a703f73-5f67-4734-b971-9df145daf67b" />

