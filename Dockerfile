FROM golang:1.23.6-alpine3.21 AS builder

WORKDIR /app
COPY . /app
RUN CGO_ENABLED=0 go build .

FROM alpine:3.21

WORKDIR /app
COPY --from=builder /app/glance .

# ✅ Copy the glance.yml config file into the expected location
COPY glance_custom/config/glance.yml /app/config/glance.yml

# ✅ (Optional) Copy assets if you’re using icons, logos, etc.
# COPY glance_custom/assets /app/assets

HEALTHCHECK --timeout=10s --start-period=60s --interval=60s \
  CMD wget --spider -q http://localhost:8080/api/healthz

EXPOSE 8080/tcp

# ✅ Make sure this path matches where you just copied the config file
ENTRYPOINT ["/app/glance", "--config", "/app/config/glance.yml"]
