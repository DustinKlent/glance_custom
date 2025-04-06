# Stage 1: Build the Go binary
FROM golang:1.23.6-alpine3.21 AS builder

WORKDIR /app
COPY . /app
RUN CGO_ENABLED=0 go build .

# Stage 2: Minimal runtime container
FROM alpine:3.21

WORKDIR /app

# Copy the built binary from builder
COPY --from=builder /app/glance .

# ✅ Copy your glance config from the correct relative path
COPY app/config/glance.yml /app/config/glance.yml

# Optional: if you add assets later
# COPY app/assets /app/assets

# Healthcheck for Render
HEALTHCHECK --timeout=10s --start-period=60s --interval=60s \
  CMD wget --spider -q http://localhost:8080/api/healthz

EXPOSE 8080

# Run Glance with the correct config path
ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
