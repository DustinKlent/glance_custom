# syntax=docker/dockerfile:1.0

# -------- Stage 1: Build the Go binary --------
FROM golang:1 AS builder

# Enable Go's toolchain auto-upgrade (needed for 1.23+)
ENV GOTOOLCHAIN=auto

WORKDIR /app

# Install git (needed for Go modules)
RUN apt-get update && apt-get install -y git

COPY go.* ./
RUN go mod download

COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o glance .

# -------- Stage 2: Minimal runtime container --------
FROM alpine:3.18

WORKDIR /app

# Copy binary
COPY --from=builder /app/glance .

# Copy config
COPY app/config/glance.yml /app/config/glance.yml

# Optional: assets
# COPY app/assets /app/assets

# Healthcheck for Render
HEALTHCHECK --timeout=10s --start-period=60s --interval=60s \
  CMD wget --spider -q http://localhost:8080/api/healthz || exit 1

EXPOSE 8080

ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
