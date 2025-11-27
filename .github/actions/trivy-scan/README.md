# Trivy Security Scan Action

A composite GitHub Action that performs comprehensive vulnerability scanning using Trivy to detect security issues in dependencies, container images, secrets, and misconfigurations.

## Features

- ✅ Filesystem and container image scanning
- ✅ Vulnerability detection (OS packages and libraries)
- ✅ Secret scanning
- ✅ Misconfiguration detection
- ✅ Automatic SARIF upload to GitHub Security tab
- ✅ Configurable severity filtering
- ✅ Directory exclusions

## ⚠️ Prerequisites

### GitHub Advanced Security Required

**Important**: This action uploads results to GitHub's Code Scanning feature, which requires **GitHub Advanced Security (GHAS)** to be enabled for your repository.

- ✅ **Public repositories**: GHAS is free and automatically available
- ⚠️ **Private repositories**: GHAS requires a paid license

#### What happens without GHAS?

- ✅ Trivy scan runs successfully
- ✅ Vulnerabilities, secrets, and misconfigurations are detected
- ✅ SARIF file is generated
- ❌ Upload to Security tab fails with error: `Advanced Security must be enabled for this repository to use code scanning`

#### Enabling GHAS

1. **Organization level**: Organization Settings → Code security and analysis → Enable GitHub Advanced Security
2. **Repository level**: Repository Settings → Code security and analysis → Enable GitHub Advanced Security

For more information, see [GitHub's GHAS documentation](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security).

#### Workaround for repositories without GHAS

If you cannot enable GHAS, set `upload-sarif: 'false'` to skip the upload step:

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
  with:
    scan-type: "fs"
    upload-sarif: "false" # Disable upload when GHAS is not available
```

This allows the scan to run and complete without errors. Results won't appear in the Security tab, but you can still view findings in the workflow logs. When GHAS is enabled, simply change to `upload-sarif: 'true'` or remove the parameter (defaults to true).

## Usage

### Basic Filesystem Scan

```yaml
jobs:
  trivy-scan:
    name: Vulnerability Scan
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run Vulnerability Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          scan-type: "fs"
          severity: "HIGH,CRITICAL"
```

### Container Image Scan

```yaml
jobs:
  scan-container:
    name: Container Vulnerability Scan
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Scan Container Image
        uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          scan-type: "image"
          scan-ref: "nvcr.io/myorg/myapp:v1.0.0"
          severity: "CRITICAL,HIGH"
```

### Advanced Filesystem Scan

```yaml
jobs:
  comprehensive-scan:
    name: Comprehensive Security Scan
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run Comprehensive Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          scan-type: "fs"
          scan-ref: "."
          vuln-type: "os,library"
          scanners: "vuln,secret,misconfig"
          severity: "MEDIUM,HIGH,CRITICAL"
          skip-dirs: "vendor,node_modules,target,test/fixtures"
          ignore-unfixed: "false"
```

## Inputs

| Input              | Description                                                                                 | Required | Default                 |
| ------------------ | ------------------------------------------------------------------------------------------- | -------- | ----------------------- |
| `scan-type`        | Type of scan (`fs` or `image`)                                                              | No       | `fs`                    |
| `scan-ref`         | Path or image reference to scan                                                             | No       | `.`                     |
| `vuln-type`        | Vulnerability types to check                                                                | No       | `os,library`            |
| `scanners`         | Scanners to use                                                                             | No       | `vuln,secret,misconfig` |
| `severity`         | Severity levels to report                                                                   | No       | `HIGH,CRITICAL`         |
| `skip-dirs`        | Directories to skip (comma-separated)                                                       | No       | `vendor,node_modules`   |
| `ignore-unfixed`   | Ignore unfixed vulnerabilities                                                              | No       | `true`                  |
| `upload-sarif`     | Upload results to GitHub Security (requires GHAS)                                           | No       | `true`                  |
| `post-pr-comment`  | Post results as PR comment (works without GHAS, needs `pull-requests: write`)               | No       | `false`                 |
| `fail-on-findings` | Fail the workflow if vulnerabilities are found (quality gate). Set to `false` to only warn. | No       | `true`                  |
| `github-token`     | GitHub token for uploading SARIF                                                            | No       | `${{ github.token }}`   |

### Scan Types

- **`fs`** - Filesystem scan (scans repository files)
- **`image`** - Container image scan (scans Docker/OCI images)

### Scanners

Combine multiple scanners (comma-separated):

- **`vuln`** - Vulnerability detection
- **`secret`** - Secret detection (API keys, tokens, etc.)
- **`misconfig`** - Misconfiguration detection (IaC, Dockerfiles, etc.)

### Vulnerability Types

- **`os`** - OS package vulnerabilities
- **`library`** - Application dependency vulnerabilities

### Severity Levels

- **`CRITICAL`** - Critical vulnerabilities
- **`HIGH`** - High severity vulnerabilities
- **`MEDIUM`** - Medium severity vulnerabilities
- **`LOW`** - Low severity vulnerabilities

## Required Permissions

Your workflow job must have the following permissions:

```yaml
permissions:
  actions: read # Required for workflow run metadata
  contents: read # Required for checking out code
  security-events: write # Required for uploading results
```

## Quality Gate

The action includes a **quality gate** feature that fails the workflow if vulnerabilities are detected:

- **Enabled by default**: `fail-on-findings: 'true'`
- **Enforces security policy**: Blocks PRs with vulnerabilities
- **Can be disabled**: Set `fail-on-findings: 'false'` to only warn

### Example: Enforce Quality Gate

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
  with:
    scan-type: "fs"
    severity: "HIGH,CRITICAL"
    fail-on-findings: "true" # Fail workflow if vulnerabilities found (default)
```

### Example: Warn Only

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
  with:
    scan-type: "fs"
    severity: "HIGH,CRITICAL"
    fail-on-findings: "false" # Only warn, don't block workflow
```

**Quality Gate Output:**

```text
📊 Trivy Scan Results:
  - Total Vulnerabilities: 5
  - Critical/High: 5

❌ Quality Gate: FAILED
Trivy detected 5 vulnerability/vulnerabilities in the scan.
Please review and remediate the issues before merging.
```

**Recommendation**: Start with `fail-on-findings: 'false'` during initial rollout, then enable it once vulnerabilities are remediated.

## Results

Scan results are automatically uploaded to GitHub's Security tab under **Security > Code scanning alerts**.

**Note**: Uploading results requires GitHub Advanced Security to be enabled. See the [Prerequisites](#️-prerequisites) section above.

### Posting Results to Pull Requests

Enable automated PR comments by setting `post-pr-comment: true`. **This works even without GHAS!**

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
  with:
    scan-type: "fs"
    post-pr-comment: "true" # Post results to PR
```

#### Requirements

- ✅ `pull-requests: write` permission
- ✅ Works with:
  - `pull_request` events (opened, synchronized, etc.)
  - `push` events to PR branches
  - Custom PR branch formats (e.g., `refs/heads/pull-request/123`)
- ❌ Does NOT require GHAS

#### Example PR Comments

**Without GHAS** (`upload-sarif: false`):

```text
## 🛡️ Vulnerability Scan
🚨 Found **8** vulnerability(ies)

**Severity Breakdown:**
- 🔴 Critical/High: 3
- 🟡 Medium: 4
- 🔵 Low/Info: 1

<details>
<summary>📋 Top Vulnerabilities</summary>

- **CVE-2024-1234**: High severity vulnerability in package X
- **CVE-2024-5678**: SQL injection in dependency Y
...
</details>

💡 **Note**: Enable GitHub Advanced Security to see full details in the Security tab.
```

**With GHAS** (`upload-sarif: true`):

```text
## 🛡️ Vulnerability Scan
🚨 Found **8** vulnerability(ies)

**Severity Breakdown:**
- 🔴 Critical/High: 3
- 🟡 Medium: 4
- 🔵 Low/Info: 1

<details>
<summary>📋 Top Vulnerabilities</summary>

- **CVE-2024-1234**: High severity vulnerability in package X
- **CVE-2024-5678**: SQL injection in dependency Y
...
</details>

🔗 [View full details in Security tab](https://github.com/owner/repo/security/code-scanning)
```

## Common Use Cases

### 1. Daily Scheduled Scan

```yaml
name: Daily Security Scan

on:
  schedule:
    - cron: "0 2 * * *" # Run at 2 AM daily

jobs:
  daily-scan:
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          severity: "CRITICAL,HIGH"
```

### 2. Pull Request Scan

```yaml
name: PR Security Check

on:
  pull_request:

jobs:
  pr-scan:
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          scan-type: "fs"
          severity: "HIGH,CRITICAL"
          ignore-unfixed: "true"
```

### 3. Post-Build Container Scan

```yaml
jobs:
  build:
    runs-on: linux-amd64-cpu4
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        # ... build steps ...
        id: meta

  scan:
    needs: build
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          scan-type: "image"
          scan-ref: ${{ needs.build.outputs.image-tag }}
```

### 4. Rust Project Scan

```yaml
jobs:
  rust-security:
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          scan-type: "fs"
          scan-ref: "."
          severity: "HIGH,CRITICAL"
          skip-dirs: "target,vendor"
```

### 5. Secret Scanning Only

```yaml
jobs:
  secret-scan:
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          scan-type: "fs"
          scanners: "secret"
          severity: "HIGH,CRITICAL"
```

## Skip Directories

Common directories to skip:

```yaml
skip-dirs: "vendor,node_modules,target,dist,build,test,docs,.git"
```

### Language-Specific Patterns

- **Go**: `vendor,go.sum`
- **Rust**: `target,Cargo.lock`
- **Node.js**: `node_modules,package-lock.json`
- **Python**: `venv,.venv,__pycache__`
- **Java**: `target,.m2`

## Troubleshooting

### No SARIF File Generated

**Issue**: No results are uploaded to GitHub Security.

**Solutions**:

1. Check if Trivy found any vulnerabilities
2. Ensure the severity level isn't too strict
3. Try with `ignore-unfixed: 'false'`

### Too Many Results

**Issue**: Scan finds too many vulnerabilities.

**Solutions**:

1. Increase severity threshold: `severity: 'CRITICAL'`
2. Enable `ignore-unfixed: 'true'`
3. Add more directories to `skip-dirs`

### Scan Timeout

**Issue**: Scan takes too long and times out.

**Solutions**:

1. Add more directories to `skip-dirs`
2. Increase job timeout
3. Split into multiple scans (e.g., separate secret scan)

### Private Registry Access

**Issue**: Cannot scan images from private registry.

**Solutions**:

1. Login to the registry before scanning:

```yaml
- name: Login to Registry
  uses: docker/login-action@v3
  with:
    registry: nvcr.io
    username: ${{ secrets.REGISTRY_USER }}
    password: ${{ secrets.REGISTRY_TOKEN }}

- name: Scan Image
  uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
  with:
    scan-type: "image"
    scan-ref: "nvcr.io/private/image:tag"
```

## Version Pinning

### Use Specific Version (Recommended for Production)

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@v1.0.0
```

### Use Latest (Development/Testing)

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
```

## What Gets Scanned

### Filesystem Scan (`scan-type: 'fs'`)

- OS package vulnerabilities (if applicable)
- Application dependencies (Go modules, Cargo.toml, package.json, etc.)
- Embedded secrets (API keys, tokens, passwords)
- IaC misconfigurations (Dockerfile, Kubernetes manifests, Terraform, etc.)

### Container Image Scan (`scan-type: 'image'`)

- OS package vulnerabilities
- Application dependencies
- Embedded secrets
- Container misconfigurations

## License

Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.

Licensed under the Apache License, Version 2.0.
