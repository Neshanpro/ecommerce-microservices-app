FROM golang:1.22-alpine AS builder

WORKDIR /usr/src/app/

COPY services/checkout/go.mod services/checkout/go.sum ./
RUN go mod download

COPY services/checkout/ ./

RUN CGO_ENABLED=0 GOOS=linux \
    go build -trimpath -ldflags="-s -w" -o /out/checkout ./

FROM alpine:3.20

RUN addgroup -S app && adduser -S app -G app

WORKDIR /usr/src/app/

COPY --from=builder --chown=app:app /out/checkout ./checkout

ENV CHECKOUT_PORT=5050
EXPOSE 5050

USER app
ENTRYPOINT ["./checkout"]
