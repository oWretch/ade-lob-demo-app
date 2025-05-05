# Build Stage
FROM golang:1.22-alpine AS builder

# Set working directory
WORKDIR /app

# Install necessary build tools
RUN apk add --no-cache git

# Copy go mod files and download dependencies
COPY go.mod ./
RUN go mod download

# Copy the source code
COPY . .

# Build the application with CGO disabled for a static binary
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Runtime Stage
FROM scratch

ARG VERSION=1.0.0

# Set working directory
WORKDIR /app

# Copy static assets and templates
COPY --from=builder /app/static/ ./static/
COPY --from=builder /app/templates/ ./templates/

# Copy the binary from the build stage
COPY --from=builder /app/app .

ENV APP_VERSION=${VERSION}

# Expose the port the app runs on
EXPOSE 8080

# Command to run the executable
ENTRYPOINT ["./app"]
