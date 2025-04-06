FROM golang:1.23.6-alpine3.21 AS builder

WORKDIR /app
COPY . /app
RUN CGO_ENABLED=0 go build .

FROM alpine:3.21

WORKDIR /app
COPY --from=builder /app/glance .

# ✅ Add this line to copy your actual config file into the expected path
COPY glance_custom/app/config/glance.yml /app/config/glance.yml

HEALTHCHECK --timeout=10s --start-period=60s --interval=60s \
  CMD wget --spider -q http://localhost:8080/api/healthz

EXPOSE 8080/tcp
ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
