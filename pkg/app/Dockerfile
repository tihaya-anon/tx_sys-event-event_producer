# ==== builder ====
FROM golang:1.24.4 AS builder

# Set working directory
WORKDIR /app

# Copy Go module files and download dependencies
COPY src/go.mod src/go.sum ./
RUN go mod tidy

# Copy the rest of the app
COPY src .

# Build Go app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o app cmd/main.go

# ==== downloader ====
FROM curlimages/curl:8.8.0 AS healthprobe-downloader

# Download and install grpc-health-probe
RUN curl -L -o /tmp/grpc-health-probe \
    https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.39/grpc_health_probe-linux-amd64

# ==== runtime ====
FROM alpine:3.20

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/app .
COPY --from=healthprobe-downloader /tmp/grpc-health-probe /usr/local/bin/grpc-health-probe

RUN chmod +x /usr/local/bin/grpc-health-probe

EXPOSE 50051
CMD ["./app"]
