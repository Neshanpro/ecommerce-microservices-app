# --- STAGE 1: Builder ---
FROM node:20-alpine AS builder
WORKDIR /usr/src/app

# Copy payment manifests from the host root path context
COPY ./services/payment/package*.json ./
RUN npm install --only=production

# Copy the payment service source code
COPY ./services/payment/ ./

# --- STAGE 2: Distroless Runtime ---
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /usr/src/app

# Copy built artifacts from stage 1
COPY --from=builder /usr/src/app ./

# Copy the shared proto file from the repository root path context
COPY ./pb/demo.proto ./demo.proto

USER 10001
EXPOSE 50051
ENV PORT=50051

CMD ["index.js"]

