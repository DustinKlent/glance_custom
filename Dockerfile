# Stage 1: Build the Go app
FROM golang:1.23.6-alpine3.21 AS builder

WORKDIR /app
COPY . /app
RUN CGO_ENABLED=0 go build .

# Stage 2: Create a minimal runtime image
FROM alpine:3.21

WORKDIR /app

# Copy the built binary from the builder stage
COPY --from=builder /app/glance .

# ✅ Copy the config file into the expected location
COPY app/config/glance.yml /app/config/glance.yml

# Optional: If you’re using assets (icons, logos, etc.)
# COPY app/assets /app/assets

# Set up a healthcheck so Render knows it's alive
HEALTHCHECK --timeout=10s --start-period=60s --interval=60s \
  CMD wget --spider -q http://localhost:8080/api/healthz

EXPOSE 8080/tcp

# ✅ Start the app with the correct config path
ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
