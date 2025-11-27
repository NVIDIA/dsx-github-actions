# DSX GitHub Actions

A collection of reusable GitHub Actions for standardizing CI/CD workflows across NVIDIA projects.

## 🚀 Available Actions

| Action                                                  | Description                       | Use Case                          |
| ------------------------------------------------------- | --------------------------------- | --------------------------------- |
| [codeql-scan](.github/actions/codeql-scan/)             | Static code analysis with CodeQL  | Security vulnerability detection  |
| [vuln-scan](.github/actions/vuln-scan/)                 | Vulnerability scanning with Trivy | Dependency and container scanning |
| [resource-push-ngc](.github/actions/resource-push-ngc/) | Push resources to NGC             | Artifact publishing               |

## ⚠️ Important: GitHub Advanced Security Required

The security scanning actions (`codeql-scan` and `vuln-scan`) upload results to GitHub's Code Scanning feature, which **requires GitHub Advanced Security (GHAS)** to be enabled:

- ✅ **Public repositories**: Free and automatically available
- ⚠️ **Private repositories**: Requires GHAS license

Without GHAS enabled, scans will run successfully but uploads will fail. See individual action documentation for workarounds and details:

- [CodeQL Prerequisites](.github/actions/codeql-scan/README.md#️-prerequisites)
- [Vuln Scan Prerequisites](.github/actions/vuln-scan/README.md#️-prerequisites)

## 📖 Quick Start

### Security Scanning (Rust)

```yaml
name: Security Checks

on: [push, pull_request]

permissions:
  contents: read
  security-events: write

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: CodeQL Analysis
        uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "rust"
          build-command: "cargo build --workspace"

      - name: Vulnerability Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/vuln-scan@main
        with:
          severity: "HIGH,CRITICAL"
          skip-dirs: "target,vendor"
```

### Security Scanning (Go)

```yaml
- name: CodeQL Analysis
  uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "go"
    build-command: "go build ./..."

- name: Vulnerability Scan
  uses: NVIDIA/dsx-github-actions/.github/actions/vuln-scan@main
```

### Container Scanning

```yaml
- name: Scan Container Image
  uses: NVIDIA/dsx-github-actions/.github/actions/vuln-scan@main
  with:
    scan-type: "image"
    scan-ref: "nvcr.io/myorg/myapp:v1.0.0"
    severity: "CRITICAL,HIGH"
```

## 📚 Documentation

- [CodeQL Scan Action](.github/actions/codeql-scan/README.md)
- [Vulnerability Scan Action](.github/actions/vuln-scan/README.md)
- [Resource Push NGC Action](.github/actions/resource-push-ngc/README.md)
- [Workflows Guide](.github/workflows/README.md)

## 🎯 Features

- ✅ **Composite Actions**: Lightweight, reusable, and flexible
- ✅ **Multi-language Support**: Go, Rust, Python, JavaScript, C++, Java, C#
- ✅ **Security Integration**: Automatic SARIF upload to GitHub Security tab
- ✅ **Configurable**: Extensive input parameters for customization
- ✅ **Well-documented**: Comprehensive README for each action

## 📦 Version Pinning

### Production (Recommended)

Use specific version tags for stability:

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@v1.0.0
```

### Development

Use `@main` for latest features:

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
```

## 🛠️ Usage Examples

### Example 1: Basic Security Pipeline

```yaml
name: Security

on: [push, pull_request]

permissions:
  contents: read
  security-events: write

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "go"
      - uses: NVIDIA/dsx-github-actions/.github/actions/vuln-scan@main
```

### Example 2: Separate Jobs for Long Scans

```yaml
jobs:
  codeql:
    runs-on: linux-amd64-cpu4
    timeout-minutes: 360
    permissions:
      security-events: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "rust"
          build-command: "cargo build --workspace"

  vuln-scan:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/vuln-scan@main
```

### Example 3: Container Build + Scan

```yaml
jobs:
  build-and-scan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4

      - name: Build Container
        run: docker build -t myapp:${{ github.sha }} .

      - name: Scan Container
        uses: NVIDIA/dsx-github-actions/.github/actions/vuln-scan@main
        with:
          scan-type: "image"
          scan-ref: "myapp:${{ github.sha }}"
```

## Contributing

1. Create action in `.github/actions/my-action/`
2. Add `action.yml` and `README.md`
3. Test with multiple projects
4. Update this README
5. Create version tag

## 📋 Repository Structure

```text
.github/
├── actions/
│   ├── codeql-scan/        # Static code analysis
│   ├── vuln-scan/          # Vulnerability scanning
│   └── resource-push-ngc/  # NGC publishing
└── workflows/
    └── README.md           # Workflows documentation

LICENSE                     # Apache 2.0
SECURITY.md                # Security policy
README.md                  # This file
```

## 📄 License

Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
