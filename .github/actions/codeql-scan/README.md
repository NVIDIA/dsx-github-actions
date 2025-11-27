# CodeQL Security Scan Action

A composite GitHub Action that performs static code analysis using GitHub's CodeQL engine to identify security vulnerabilities, bugs, and code quality issues.

## Features

- ✅ Multi-language support (Go, Rust, Python, JavaScript, C++, Java, C#)
- ✅ Customizable build commands
- ✅ Automatic SARIF upload to GitHub Security tab
- ✅ Manual build mode for complex projects
- ✅ Configurable analysis categories

## ⚠️ Prerequisites

### GitHub Advanced Security Required

**Important**: This action uploads results to GitHub's Code Scanning feature, which requires **GitHub Advanced Security (GHAS)** to be enabled for your repository.

- ✅ **Public repositories**: GHAS is free and automatically available
- ⚠️ **Private repositories**: GHAS requires a paid license

#### What happens without GHAS?

- ✅ CodeQL analysis runs successfully
- ✅ Security issues are detected
- ✅ SARIF file is generated
- ❌ Upload to Security tab fails with error: `Advanced Security must be enabled for this repository to use code scanning`

#### Enabling GHAS

1. **Organization level**: Organization Settings → Code security and analysis → Enable GitHub Advanced Security
2. **Repository level**: Repository Settings → Code security and analysis → Enable GitHub Advanced Security

For more information, see [GitHub's GHAS documentation](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security).

#### Workaround for repositories without GHAS

If you cannot enable GHAS, set `upload-sarif: 'false'` to skip the upload step:

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "go"
    upload-sarif: "false" # Disable upload when GHAS is not available
```

This allows the scan to run and complete without errors. Results won't appear in the Security tab, but you can still view findings in the workflow logs. When GHAS is enabled, simply change to `upload-sarif: 'true'` or remove the parameter (defaults to true).

## Usage

### Basic Example

```yaml
jobs:
  security-scan:
    name: CodeQL Security Analysis
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run CodeQL Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "go"
          build-mode: "manual"
          build-command: "go build ./..."
```

### Rust Project Example

```yaml
jobs:
  codeql-rust:
    name: CodeQL Security Analysis
    runs-on: linux-amd64-cpu4
    timeout-minutes: 360
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Rust
        uses: actions-rust-lang/setup-rust-toolchain@v1

      - name: Run CodeQL Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "rust"
          build-mode: "none"
          category: "/language:rust"
```

### Python Project Example

```yaml
jobs:
  codeql-python:
    name: CodeQL Security Analysis
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install -r requirements.txt

      - name: Run CodeQL Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "python"
          build-mode: "none"
```

## Inputs

| Input              | Description                                                                                                                           | Required | Default               |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------- |
| `languages`        | Programming language to analyze                                                                                                       | No       | `go`                  |
| `build-mode`       | Build mode: `autobuild`, `manual`, or `none` (use `none` for Rust)                                                                    | No       | `autobuild`           |
| `build-command`    | Build command (only used when build-mode is `manual`)                                                                                 | No       | `make build-all`      |
| `category`         | CodeQL analysis category                                                                                                              | No       | `/language:default`   |
| `upload-sarif`     | Upload results to GitHub Security (requires GHAS)                                                                                     | No       | `true`                |
| `skip-build`       | Skip build step (only for `build-mode: none`)                                                                                         | No       | `false`               |
| `post-pr-comment`  | Post results as PR comment (works without GHAS, needs `pull-requests: write`)                                                         | No       | `false`               |
| `fail-on-findings` | Fail the workflow if security issues are found (quality gate). Set to `false` to only warn.                                           | No       | `true`                |
| `fail-on-severity` | Minimum severity to fail: `error` (critical/high), `warning` (medium+), `note` (all). Only applies when `fail-on-findings` is `true`. | No       | `error`               |
| `github-token`     | GitHub token for CodeQL actions                                                                                                       | No       | `${{ github.token }}` |

### Supported Languages

- `go` - Go
- `rust` - Rust
- `python` - Python
- `javascript` - JavaScript/TypeScript
- `cpp` - C/C++
- `java` - Java
- `csharp` - C#

### Build Modes

CodeQL supports different build modes depending on the language:

- **`none`** - No build required. CodeQL analyzes source code directly.

  - **Required for**: Rust
  - **Optional for**: Python, JavaScript/TypeScript

- **`autobuild`** - CodeQL automatically detects and runs your build.

  - **Works for**: Most languages (default)
  - **Use when**: You have a standard build setup

- **`manual`** - You specify the exact build command.
  - **Required for**: Custom build processes
  - **Works for**: Go, C/C++, Java, C#
  - **Use when**: You need specific build flags or steps

**Important**: Rust does **not** support `manual` or `autobuild` modes. Always use `build-mode: 'none'` for Rust.

## Required Permissions

Your workflow job must have the following permissions:

```yaml
permissions:
  actions: read # Required for workflow run metadata
  contents: read # Required for checking out code
  security-events: write # Required for uploading results
```

## Quality Gate

The action includes a **quality gate** feature with configurable severity thresholds:

- **Enabled by default**: `fail-on-findings: 'true'`
- **Severity-based**: Use `fail-on-severity` to control which issues block the workflow
- **Flexible**: Can be disabled or configured for different severity levels

### Severity Levels

CodeQL maps findings to three severity levels:

| Level     | CodeQL SARIF Level | Severity      | Use Case                                                |
| --------- | ------------------ | ------------- | ------------------------------------------------------- |
| `error`   | error              | Critical/High | **Recommended** - Block only on serious security issues |
| `warning` | warning            | Medium        | Block on medium+ severity issues                        |
| `note`    | note               | Low/Info      | Block on all findings including informational           |

### Example: Block on Critical/High Only (Recommended)

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "go"
    fail-on-findings: "true"
    fail-on-severity: "error" # Only fail on critical/high severity (default)
```

**Output:**

```text
📊 CodeQL Results:
  - Total Issues: 5
  - 🔴 Errors (Critical/High): 2
  - 🟡 Warnings (Medium): 2
  - 🔵 Notes (Low/Info): 1

🎯 Quality Gate Threshold: Fail on ERRORS only

❌ Quality Gate: FAILED
CodeQL detected 2 errors (critical/high) in the code.
Please review and fix the issues before merging.
```

### Example: Block on Medium+ Severity

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "go"
    fail-on-findings: "true"
    fail-on-severity: "warning" # Fail on errors and warnings
```

**Output:**

```text
📊 CodeQL Results:
  - Total Issues: 5
  - 🔴 Errors (Critical/High): 2
  - 🟡 Warnings (Medium): 2
  - 🔵 Notes (Low/Info): 1

🎯 Quality Gate Threshold: Fail on ERRORS and WARNINGS

❌ Quality Gate: FAILED
CodeQL detected 4 errors and warnings (medium+) in the code.
Please review and fix the issues before merging.
```

### Example: Block on All Issues

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "go"
    fail-on-findings: "true"
    fail-on-severity: "note" # Fail on any finding
```

### Example: Warn Only (No Blocking)

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "go"
    fail-on-findings: "false" # Disabled, only warn
```

**Recommendation**:

1. **Start with**: `fail-on-severity: 'error'` (critical/high only) - good balance between security and developer productivity
2. **Stricter**: `fail-on-severity: 'warning'` (medium+) - for high-security projects
3. **Most strict**: `fail-on-severity: 'note'` (all issues) - for security-critical code

## Build Commands

The `build-command` is only used when `build-mode` is set to `manual`.

**Examples for manual build mode**:

- **Go**: `go build ./...`
- **C/C++**: `make` or `cmake --build build`
- **Java**: `mvn compile` or `gradle build`
- **C#**: `dotnet build`

**Note**:

- Rust does not support manual build mode - use `build-mode: 'none'` instead
- Python/JavaScript typically use `build-mode: 'none'` or `'autobuild'`

## Results

Analysis results are automatically uploaded to GitHub's Security tab under **Security > Code scanning alerts**.

**Note**: Uploading results requires GitHub Advanced Security to be enabled. See the [Prerequisites](#️-prerequisites) section above.

## Advanced Usage

### Multiple Languages

Run separate jobs for each language:

```yaml
jobs:
  codeql-go:
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "go"
          build-mode: "manual"
          build-command: "go build ./..."
          category: "/language:go"

  codeql-javascript:
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "javascript"
          build-mode: "none"
          category: "/language:javascript"
```

### Custom GitHub Token

If you need to use a custom token (e.g., for private dependencies):

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "go"
    build-command: "go build ./..."
    github-token: ${{ secrets.CUSTOM_GITHUB_TOKEN }}
```

### Skipping Build Step

The `skip-build` parameter is useful when using `build-mode: none` and you want to explicitly skip any build steps:

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "rust"
    build-mode: "none"
    skip-build: "true" # No build needed - source analysis only
```

#### Important: Pre-Built Artifacts and CodeQL

CodeQL's requirements vary by language:

| Language Type         | Build Mode | Can Use Pre-Built Artifacts?                   |
| --------------------- | ---------- | ---------------------------------------------- |
| **Rust**              | `none`     | ❌ No artifacts needed - analyzes source only  |
| **Python/JavaScript** | `none`     | ❌ No artifacts needed - analyzes source only  |
| **Go/C++/Java/C#**    | `manual`   | ❌ **Cannot use pre-built** - must trace build |

#### Why traced languages can't use pre-built artifacts

For Go, C++, Java, and C#, CodeQL must **observe the build process** to:

- Track compilation steps
- Understand code dependencies
- Map source to compiled output
- Extract semantic information

Pre-built binaries don't contain this information.

#### When to use `skip-build: true`

1. **Source-only languages** (Rust, Python, JavaScript) - CodeQL doesn't need a build at all
2. **After failed build** - Still want to analyze available source code
3. **Documentation/config scanning** - Only analyzing non-compiled files

#### Example: Rust (no build artifacts needed)

```yaml
jobs:
  codeql-rust:
    steps:
      - uses: actions/checkout@v4
      # No build step needed at all
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "rust"
          build-mode: "none" # Analyzes source code directly
```

#### Example: Go (must build during scan)

```yaml
jobs:
  codeql-go:
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "go"
          build-mode: "manual"
          build-command: "go build ./..." # CodeQL traces this build
          # skip-build: false (must build during scan)
```

### Posting Results to Pull Requests

Enable automated PR comments by parsing the SARIF results file. **This works even without GHAS!**

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
  with:
    languages: "rust"
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
## 🛡️ CodeQL Analysis
🚨 Found **5** issue(s)

**Severity Breakdown:**
- 🔴 Errors: 2
- 🟡 Warnings: 3
- 🔵 Notes: 0

<details>
<summary>📋 Top Issues</summary>

- **go/sql-injection**: Potential SQL injection (db/query.go:45)
- **go/path-injection**: Path traversal vulnerability (api/handler.go:23)
...
</details>

💡 **Note**: Enable GitHub Advanced Security to see full details in the Security tab.
```

**With GHAS** (`upload-sarif: true`):

```text
## 🛡️ CodeQL Analysis
🚨 Found **5** issue(s)

**Severity Breakdown:**
- 🔴 Errors: 2
- 🟡 Warnings: 3
- 🔵 Notes: 0

<details>
<summary>📋 Top Issues</summary>

- **go/sql-injection**: Potential SQL injection (db/query.go:45)
- **go/path-injection**: Path traversal vulnerability (api/handler.go:23)
...
</details>

🔗 [View full details in Security tab](https://github.com/owner/repo/security/code-scanning)
```

#### Complete Example (Without GHAS)

```yaml
jobs:
  codeql:
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write
      pull-requests: write # Required for PR comments
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "rust"
          build-mode: "none"
          upload-sarif: "false" # GHAS not enabled
          post-pr-comment: "true" # Works without GHAS!
```

#### Complete Example (With GHAS)

```yaml
jobs:
  codeql:
    permissions:
      actions: read
      contents: read
      security-events: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "go"
          build-mode: "manual"
          build-command: "go build ./..."
          upload-sarif: "true" # Upload to Security tab
          post-pr-comment: "true" # Also post to PR
```

## Troubleshooting

### Can I Use Pre-Built Artifacts from a Previous Job?

**Question**: I want to build in one job and run CodeQL in another using the artifacts.

**Answer**: This depends on the language:

#### ❌ Not Possible for Traced Languages (Go, C++, Java, C#)

- CodeQL must observe the **build process itself**
- Pre-compiled binaries don't contain the necessary semantic information
- You must build within the CodeQL job

#### ✅ Not Needed for Source Languages (Rust, Python, JavaScript)

- CodeQL analyzes source code directly
- No build artifacts are needed at all
- Just checkout the code and run the scan

#### Alternative: Build and Scan in Same Job

For traced languages, include both in one job:

```yaml
jobs:
  build-and-scan:
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5

      # CodeQL will trace this build
      - uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "go"
          build-mode: "manual"
          build-command: "go build ./..."

      # Artifacts are available after CodeQL completes
      - uses: actions/upload-artifact@v4
        with:
          name: binaries
          path: bin/
```

### Build Fails During CodeQL Analysis

**Issue**: The build command fails during CodeQL analysis.

**Solutions**:

1. Ensure all dependencies are installed before running the action
2. Test your build command locally first
3. Check that environment variables are set correctly
4. For complex builds, consider setting up the environment in a previous step

### "No source code was seen during the build"

**Issue**: CodeQL doesn't detect any code being analyzed.

**Solutions**:

1. Ensure your build command actually compiles source code
2. Check that the `languages` input matches your project
3. For interpreted languages (Python, JavaScript), ensure files are present

### Timeout Issues

**Issue**: CodeQL analysis times out.

**Solutions**:

1. Increase the job timeout: `timeout-minutes: 360`
2. Use a more powerful runner
3. Build only what's necessary (avoid `--all-targets` if not needed)

## Version Pinning

### Use Specific Version (Recommended for Production)

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@v1.0.0
```

### Use Latest (Development/Testing)

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
```

## License

Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.

Licensed under the Apache License, Version 2.0.
