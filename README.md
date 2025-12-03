# DSX GitHub Actions

A collection of reusable GitHub Actions for standardizing CI/CD workflows across NVIDIA projects.

## 🚀 Available Actions

| Action                                                  | Description                       | Use Case                          |
| ------------------------------------------------------- | --------------------------------- | --------------------------------- |
| [codeql-scan](.github/actions/codeql-scan/)             | Static code analysis with CodeQL  | Security vulnerability detection  |
| [trivy-scan](.github/actions/trivy-scan/)               | Vulnerability scanning with Trivy | Dependency and container scanning |
| [trufflehog-scan](.github/actions/trufflehog-scan/)     | Secret scanning with TruffleHog   | Leaked credentials detection      |
| [semantic-release](.github/actions/semantic-release/)   | Automated versioning and releases | Semantic versioning and changelog |
| [resource-push-ngc](.github/actions/resource-push-ngc/) | Push resources to NGC             | Artifact publishing               |
| [git-tag](.github/actions/git-tag/)                     | Create and push git tag           | Tagging releases                  |
| [slack-notify](.github/actions/slack-notify/)           | Send notifications to Slack       | CI/CD status notifications        |

## ♻️ Available Workflows

| Workflow                                                                 | Description                                           | Use Case                                |
| ------------------------------------------------------------------------ | ----------------------------------------------------- | --------------------------------------- |
| [promote-image](.github/workflows/promote-image.yml) | Re-tag and re-publish multi-arch images via `skopeo` | Promote OCI images across registries |

## ⚠️ Important: GitHub Advanced Security Required

The security scanning actions (`codeql-scan` and `trivy-scan`) upload results to GitHub's Code Scanning feature, which **requires GitHub Advanced Security (GHAS)** to be enabled:

- ✅ **Public repositories**: Free and automatically available
- ⚠️ **Private repositories**: Requires GHAS license

Without GHAS enabled, scans will run successfully but uploads will fail. See individual action documentation for workarounds and details:

- [CodeQL Prerequisites](.github/actions/codeql-scan/README.md#️-prerequisites)
- [Vuln Scan Prerequisites](.github/actions/trivy-scan/README.md#️-prerequisites)

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
    runs-on: linux-amd64-cpu4
    steps:
      - uses: actions/checkout@v4

      - name: CodeQL Analysis
        uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "rust"
          build-command: "cargo build --workspace"

      - name: Vulnerability Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
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
  uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
```

### Container Scanning

```yaml
- name: Scan Container Image
  uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
  with:
    scan-type: "image"
    scan-ref: "nvcr.io/myorg/myapp:v1.0.0"
    severity: "CRITICAL,HIGH"
```

### Image Promotion
```yaml
name: Promote OCI Image

on:
  workflow_dispatch:
    inputs:
      new-tag:
        type: string
        required: true

jobs:
  promote:
    uses: NVIDIA/dsx-github-actions/.github/workflows/promote-image.yml@main
    with:
      source: nvcr.io/acme/dev/service
      source_tag: faf3d1
      destination: nvcr.io/acme/stg/service
      destination_tag: ${{ github.event.inputs.new-tag }}
    secrets:
      SOURCE_USERNAME: ${{ secrets.NVCR_DEV_USER }}
      SOURCE_PASSWORD: ${{ secrets.NVCR_DEV_TOKEN }}
      DEST_USERNAME: ${{ secrets.NVCR_STG_USER }}
      DEST_PASSWORD: ${{ secrets.NVCR_STG_TOKEN }}
```

This reusable workflow wraps `skopeo copy`, so it copies the entire manifest list (multi-arch) by default, supports tag-to-tag retagging, and also allows pinning a specific digest by supplying the optional `digest` input. Pass GitHub Container Registry (GHCR) or NVIDIA Container Registry (NGC) credentials through the required secrets block to authenticate against different registries, and consume the resulting `${{ needs.promote.outputs.destination_digest }}` output if downstream jobs need the promoted digest.

## 📚 Documentation

- [CodeQL Scan Action](.github/actions/codeql-scan/README.md)
- [Trivy Scan Action](.github/actions/trivy-scan/README.md)
- [TruffleHog Secret Scan Action](.github/actions/trufflehog-scan/README.md)
- [Semantic Release Action](.github/actions/semantic-release/README.md)
- [Resource Push NGC Action](.github/actions/resource-push-ngc/README.md)
- [Slack Notify Action](.github/actions/slack-notify/README.md)
- [Workflows Guide](.github/workflows/README.md)

## 🎯 Features

- ✅ **Composite Actions**: Lightweight, reusable, and flexible
- ✅ **Multi-language Support**: Go, Rust, Python, JavaScript, C++, Java, C#
- ✅ **Comprehensive Security**: CodeQL, Trivy, and TruffleHog scanning
- ✅ **Secret Detection**: 700+ credential types with verification
- ✅ **Security Integration**: Automatic SARIF upload to GitHub Security tab
- ✅ **PR Comments**: Automated security findings on pull requests
- ✅ **Configurable**: Extensive input parameters for customization
- ✅ **Well-documented**: Comprehensive README for each action
- ✅ **Automatic Versioning**: Semantic releases on every commit

## 📦 Version Pinning

This repository uses **automatic semantic versioning**. Tags are automatically created on every push to `main` using [Conventional Commits](https://www.conventionalcommits.org/).

### Recommended Approaches

#### 1. Pin to Specific Commit SHA (Recommended by NVIDIA Security Guidence)

Maximum stability and security - the target action never changes:

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@55d1e0af17fb4431edaca19fbd5c78fecd29d18a
```

✅ **Best for**: Production, CI/CD pipelines
⚠️ **Note**: Won't receive bug fixes or new features automatically

#### 2. Pin to Specific Version

Maximum stability - version never changes:

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@v1.2.3
```

✅ **Best for**: Production, CI/CD pipelines
⚠️ **Note**: Won't receive bug fixes or new features automatically

#### 3. Pin to Major Version

Get patches and features, avoid breaking changes:

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@v1
```

✅ **Best for**: Most use cases
📦 **Updates**: Automatically gets `v1.x.x` updates
🛡️ **Safety**: Won't update to `v2.0.0` (breaking changes)

#### 4. Use Latest Main

Always use latest code:

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
```

⚠️ **Best for**: Development and testing only
⚠️ **Risk**: May include breaking changes

### Semantic Versioning

Version format: `vMAJOR.MINOR.PATCH`

- **MAJOR** (`v2.0.0`): Breaking changes - update your workflows
- **MINOR** (`v1.1.0`): New features - backward compatible
- **PATCH** (`v1.0.1`): Bug fixes - backward compatible

### Finding Available Versions

View all releases: [GitHub Releases](../../releases)

```bash
# List all tags
git ls-remote --tags https://github.com/NVIDIA/dsx-github-actions.git
```

### Automatic Versioning

This repository uses automatic semantic versioning:

- 🤖 **Automated**: Tags are created automatically on push to `main`
- 📝 **Conventional Commits**: Version bumps based on commit messages
- 📦 **Dual Tags**: Both specific (`v1.2.3`) and major (`v1`) tags are created

**See**: [Release Workflow Documentation](.github/workflows/README.md) for details.

## 🛠️ Usage Examples

### Example 1: Complete Security Pipeline

```yaml
name: Security

on: [push, pull_request]

permissions:
  contents: read
  security-events: write
  pull-requests: write

jobs:
  scan:
    runs-on: linux-amd64-cpu4
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Required for TruffleHog

      # Secret scanning
      - uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@55d1e0af17fb4431edaca19fbd5c78fecd29d18a
        with:
          post-pr-comment: "true"

      # Code analysis
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@55d1e0af17fb4431edaca19fbd5c78fecd29d18a
        with:
          languages: "go"
          post-pr-comment: "true"

      # Vulnerability scanning
      - uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@55d1e0af17fb4431edaca19fbd5c78fecd29d18a
        with:
          post-pr-comment: "true"
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

  trivy-scan:
    runs-on: linux-amd64-cpu4
    permissions:
      security-events: write
      contents: read
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
```

### Example 3: Container Build + Scan

```yaml
jobs:
  build-and-scan:
    runs-on: linux-amd64-cpu4
    permissions:
      contents: read
      security-events: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      # Scan for secrets in source code
      - name: Secret Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
        with:
          post-pr-comment: "true"

      - name: Build Container
        run: docker build -t myapp:${{ github.sha }} .

      # Scan container for vulnerabilities
      - name: Scan Container
        uses: NVIDIA/dsx-github-actions/.github/actions/trivy-scan@main
        with:
          scan-type: "image"
          scan-ref: "myapp:${{ github.sha }}"
          post-pr-comment: "true"
```

## 🧹 Developer Workflow

This repository ships with a [`pre-commit`](https://pre-commit.com/) configuration to lint YAML, trim whitespace, run ShellCheck on shell scripts, and execute `actionlint` against GitHub workflows before every commit.

1. Install `pre-commit` (pick one)
   - `pipx install pre-commit`
   - `pip install pre-commit`
   - `brew install pre-commit`
2. Run `pre-commit install` at the repository root to enable the git hook.
3. Run `pre-commit run --all-files` once to ensure every workflow and shell script passes ShellCheck/actionlint.

If CI still fails, execute `pre-commit run actionlint --all-files` or `pre-commit run shellcheck --all-files` locally to focus on the failing hook.

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
│   ├── codeql-scan/        # Static code analysis (CodeQL)
│   ├── trivy-scan/         # Vulnerability scanning (Trivy)
│   ├── trufflehog-scan/    # Secret scanning (TruffleHog)
│   ├── semantic-release/   # Automated versioning and releases
│   ├── resource-push-ngc/  # NGC resources publishing
│   ├── git-tag/            # Create and push git tag
│   └── slack-notify/       # Send Slack notifications
└── workflows/
    ├── release.yml         # Automatic semantic versioning
    ├── promote-image.yml   # Promote image across registries
    └── README.md           # Workflows documentation

CONTRIBUTING.md             # Contribution guidelines
LICENSE                     # Apache 2.0
SECURITY.md                 # Security policy
README.md                   # This file
```

## 📄 License

Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
