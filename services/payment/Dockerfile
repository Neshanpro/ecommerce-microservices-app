# --- STAGE 1: Builder ---
FROM node:20-alpine AS builder
WORKDIR /usr/src/app

COPY ./services/payment/package*.json ./
RUN npm install --only=production

COPY ./services/payment/ ./

# --- STAGE 2: Distroless Runtime ---
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /usr/src/app

COPY --from=builder /usr/src/app ./

# Copy the shared proto file from the repository root path context
COPY ./pb/demo.proto ./demo.proto

USER 10001
EXPOSE 50051
ENV PAYMENT_PORT=50051

ENTRYPOINT ["/nodejs/bin/node"]
CMD ["index.js"]
