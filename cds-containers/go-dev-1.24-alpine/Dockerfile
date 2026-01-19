FROM golang:1.24.3-alpine

# Set locale for proper terminal support
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install development tools and dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    vim \
    bash \
    build-base \
    procps \
    net-tools \
    ca-certificates

# Install Air for hot reloading
RUN go install github.com/air-verse/air@v1.62.0

# Install Delve for debugging
RUN go install github.com/go-delve/delve/cmd/dlv@v1.25.2

# Install other useful development tools
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.64.8
RUN go install golang.org/x/tools/cmd/goimports@v0.37.0
RUN go install github.com/swaggo/swag/cmd/swag@v1.16.4

# Enable CGO for development (allows for better debugging and some dev tools)
ENV CGO_ENABLED=1

WORKDIR /go/src/app
