# syntax=docker/dockerfile:1.0

# -------- Stage 1: Build the Go binary --------
FROM golang:1.21-alpine AS builder

# Install git (if needed for go modules)
RUN apk add --no-cache git

WORKDIR /app
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o glance .

# -------- Stage 2: Minimal runtime container --------
FROM alpine:3.18

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/glance .

# Copy Glance config file
COPY app/config/glance.yml /app/config/glance.yml

# Optional: Uncomment if you have assets
# COPY app/assets /app/assets

# Healthcheck for Render
HEALTHCHECK --timeout=10s --start-period=60s --interval=60s \
  CMD wget --spider -q http://localhost:8080/api/healthz || exit 1

EXPOSE 8080

# Run Glance
ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
