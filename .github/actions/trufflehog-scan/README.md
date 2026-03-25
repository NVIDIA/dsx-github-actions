# TruffleHog Secret Scan Action

A composite GitHub Action that wraps the [official TruffleHog action](https://github.com/trufflesecurity/trufflehog) to find and verify leaked credentials, API keys, tokens, and other secrets in your source code, with added support for PR comments.

## Features

- ✅ Detects 700+ secret types (AWS keys, GitHub tokens, API keys, etc.)
- ✅ Verifies secrets to reduce false positives
- ✅ Scans git history, not just current files
- ✅ Automatic PR comments with findings
- ✅ Configurable fail behavior
- ✅ Works with push, pull_request, and scheduled events

## ⚠️ What TruffleHog Scans

TruffleHog scans **git commit history** for:

- 🔑 API keys and tokens
- 🔐 Passwords and credentials
- 🎫 OAuth tokens
- 🗝️ Private keys
- 💳 Sensitive data patterns
- 📧 Email/username combinations

**Note**: TruffleHog scans git history, so even if you deleted a secret in a later commit, it will still be found in the history!

## Usage

### Basic Example

```yaml
jobs:
  secret-scan:
    runs-on: linux-amd64-cpu4
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Fetch full history for scanning

      - name: TruffleHog Secret Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
```

### Pull Request Scan

```yaml
name: Secret Scan

on:
  pull_request:

jobs:
  trufflehog:
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read # For direct job URL links
      contents: read
      pull-requests: write # For PR comments
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
        with:
          post-pr-comment: "true" # Post findings to PR
```

### Push Event (Scan New Commits)

```yaml
name: Secret Scan

on:
  push:
    branches: [main]

jobs:
  trufflehog:
    runs-on: linux-amd64-cpu4
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
        with:
          extra-args: "--results=verified,unknown" # Only show verified/unknown secrets
```

### Scan Specific Commit Range

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
  with:
    base: "main"
    head: "feature-branch"
```

### Advanced Configuration

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
  with:
    path: "./src"
    version: "3.63.0"
    extra-args: "--results=verified,unknown --json"
    post-pr-comment: "true"
```

## Inputs

| Input              | Description                                                                         | Required | Default               |
| ------------------ | ----------------------------------------------------------------------------------- | -------- | --------------------- |
| `path`             | Repository path to scan                                                             | No       | `./`                  |
| `base`             | Start scanning from this commit/branch                                              | No       | `''`                  |
| `head`             | Scan commits until this commit/branch                                               | No       | `''`                  |
| `extra-args`       | Extra arguments to pass to TruffleHog CLI                                           | No       | `''`                  |
| `version`          | TruffleHog version to use                                                           | No       | `latest`              |
| `post-pr-comment`  | Post results as PR comment                                                          | No       | `false`               |
| `fail-on-findings` | Fail the workflow if secrets are found (quality gate). Set to `false` to only warn. | No       | `true`                |
| `github-token`     | GitHub token for PR comments                                                        | No       | `${{ github.token }}` |

### Common Extra Arguments

- `--results=verified,unknown` - Only report verified or unknown secrets (reduces false positives)
- `--only-verified` - Only report verified secrets
- `--exclude-paths=<pattern>` - Exclude file patterns
- `--include-paths=<pattern>` - Only scan specific paths
- `--json` - Output in JSON format
- `--debug` - Enable debug logging
- `--no-update` - Skip version update check

See [TruffleHog documentation](https://github.com/trufflesecurity/trufflehog#usage) for all options.

## Required Permissions

Basic scan (no PR comments):

```yaml
permissions:
  contents: read
```

With PR comments (recommended):

```yaml
permissions:
  actions: read # Required for direct job URL links in PR comments
  contents: read
  pull-requests: write
```

**Note**: The `actions: read` permission is required to fetch the job ID via GitHub API for direct job links in PR comments. Without it, the action will fall back to linking to the workflow run (users will need to click through to find the job).

## Quality Gate

The action includes a **quality gate** feature that can fail the workflow if secrets are detected:

- **Enabled by default**: `fail-on-findings: 'true'`
- **Enforces security policy**: Prevents PRs with secrets from being merged
- **Can be disabled**: Set `fail-on-findings: 'false'` to only warn without blocking

### Example: Enforce Quality Gate

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
  with:
    extra-args: "--results=verified,unknown"
    fail-on-findings: "true" # Fail workflow if secrets found (default)
```

### Example: Warn Only (No Blocking)

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
  with:
    extra-args: "--results=verified,unknown"
    fail-on-findings: "false" # Only warn, don't block workflow
```

**Recommendation**: Start with `fail-on-findings: 'false'` during initial rollout, then enable it once your codebase is clean.

## How It Works

### Event-Based Scanning

TruffleHog automatically adjusts based on the GitHub event:

#### Push Event

- Scans commits between `github.event.before` and `github.event.after`
- Only scans new commits added in the push

#### Pull Request Event

- Scans commits between PR base and head
- Only scans changes in the PR

#### Workflow Dispatch / Schedule

- Scans entire repository history
- Use with caution on large repos

### Manual Commit Range

Override automatic detection:

```yaml
with:
  base: "v1.0.0"
  head: "main"
```

### PR Comment Intelligence

When `post-pr-comment` is enabled, the action:

1. **Wraps Official Action**: Uses the battle-tested `trufflesecurity/trufflehog@main` action
2. **Parses Exit Code**: Detects secrets based on TruffleHog's exit code
   - `0` = No secrets found (clean)
   - `183` = Secrets detected
   - `1` = Error during scan
3. **Fetches Job URL**: Uses GitHub API with intelligent job identification
   - **Primary**: Matches job by exact job name (`github.job`) - most reliable!
   - **Fallback**: Uses currently in-progress job if name match fails
   - **Last resort**: Links to workflow run if job ID cannot be determined
   - Automatically adds PR number parameter for PR contexts
4. **Generates Smart Comments**: Creates informative PR comments with:
   - Clear status indicators (✅ clean, 🚨 secrets detected, ⚠️ warnings)
   - **Direct links to the specific job logs** (intelligently identified)
   - Actionable remediation steps
   - Security best practices
5. **Handles All Events**: Works with push, pull_request, and custom branch formats

The PR comments include a **direct link to the specific scan job**, so you can immediately see the full TruffleHog output with file names, line numbers, secret types, and verification status.

**Note**: Requires `actions: read` permission for job URL fetching. Without it, falls back to workflow run URL.

## Example PR Comments

### When No Secrets Found

```text
## 🔐 TruffleHog Secret Scan
✅ **No secrets or credentials found!**

Your code has been scanned for 700+ types of secrets and credentials. All clear! 🎉

🔗 [View scan details](https://github.com/owner/repo/actions/runs/123456/job/987654321?pr=5)
```

### When Secrets Are Detected

```text
## 🔐 TruffleHog Secret Scan
🚨 **Potential secrets detected!**

TruffleHog found potential secrets in your code changes. This could include:
- 🔑 API keys and tokens
- 🔐 Passwords and credentials
- 🎫 OAuth tokens
- 🗝️ Private keys

### 📋 View Detailed Findings

👉 **[Click here to view the full TruffleHog scan results](https://github.com/owner/repo/actions/runs/123456/job/987654321?pr=5)**

The job logs contain:
- Exact file paths and line numbers
- Secret types detected
- Verification status (verified/unverified)

### Next Steps

1. **Review Details**: Check the [scan logs](https://github.com/owner/repo/actions/runs/123456/job/987654321?pr=5) for specific findings
2. **Verify Findings**: Determine if detected items are actual secrets
3. **Remove Secrets**: If real, remove them from your code immediately
4. **Rotate Credentials**: Revoke and regenerate any leaked credentials
5. **Prevent Future Leaks**: Add sensitive files to `.gitignore`

### Security Best Practices

⚠️ **Never commit secrets to your repository!** Use:
- Environment variables for configuration
- Secret management tools (Vault, AWS Secrets Manager, etc.)
- GitHub Secrets for CI/CD workflows
- `.env` files (added to `.gitignore`)

📖 [Learn more about TruffleHog](https://github.com/trufflesecurity/trufflehog)
```

## Examples

### Example 1: Basic Secret Scanning

```yaml
name: Security

on: [push, pull_request]

jobs:
  secrets:
    runs-on: linux-amd64-cpu4
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
```

### Example 2: PR with Comments

```yaml
name: PR Security Check

on:
  pull_request:

jobs:
  secrets:
    runs-on: linux-amd64-cpu4
    permissions:
      actions: read # For direct job URL links
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
        with:
          extra-args: "--results=verified,unknown"
          post-pr-comment: "true"
```

### Example 3: Only Verified Secrets

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
  with:
    extra-args: "--only-verified"
```

### Example 4: Exclude Vendor/Dependencies

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
  with:
    extra-args: "--results=verified,unknown --exclude-paths=vendor/ --exclude-paths=node_modules/"
```

### Example 5: Complete Security Suite

Combine with other security actions:

```yaml
name: Complete Security Scan

on: [push, pull_request]

permissions:
  actions: read # For direct job URL links
  contents: read
  security-events: write
  pull-requests: write

jobs:
  security:
    runs-on: linux-amd64-cpu4
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      # Secret scanning
      - name: TruffleHog Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
        with:
          post-pr-comment: "true"

      # Code analysis
      - name: CodeQL Scan
        uses: NVIDIA/dsx-github-actions/.github/actions/codeql-scan@main
        with:
          languages: "go"
          post-pr-comment: "true"

      # Note: trivy-scan has been removed due to the 2026-03 supply chain compromise.
      # See: https://github.com/aquasecurity/trivy/discussions/10425
```

## Troubleshooting

### "Not a git repository" Error

**Issue**: TruffleHog requires a git repository.

**Solution**: Ensure you checkout the repository with git history:

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0 # Important! Fetch full history
```

### No Secrets Found (But You Know There Are Some)

**Issue**: TruffleHog only scans the specified commit range.

**Solutions**:

1. Ensure `fetch-depth: 0` to get full history
2. Check `base` and `head` commits are correct
3. Try scanning entire repo: don't specify `base` or `head`

### Too Many False Positives

**Issue**: TruffleHog reports unverified secrets.

**Solutions**:

1. Use `--only-verified` to reduce false positives:
   ```yaml
   extra-args: "--only-verified"
   ```
2. Exclude test files:
   ```yaml
   extra-args: "--exclude-paths=test/ --exclude-paths=*.test.js"
   ```

### Docker Permission Issues

**Issue**: Docker command fails with permission error.

**Solution**: Ensure Docker is available on the runner. GitHub's default runners include Docker.

### Scan Takes Too Long

**Issue**: Scanning large repository history is slow.

**Solutions**:

1. Scan only recent commits:
   ```yaml
   with:
     base: "HEAD~10" # Only last 10 commits
   ```
2. Use scheduled scans instead of every push
3. Exclude large directories:
   ```yaml
   extra-args: "--exclude-paths=vendor/ --exclude-paths=dist/"
   ```

## Best Practices

### 1. Scan on Every PR

Catch secrets before they reach main:

```yaml
on:
  pull_request:
```

### 2. Use `fetch-depth: 0`

Always fetch full git history:

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0
```

### 3. Filter Results

Reduce false positives by filtering results:

```yaml
with:
  extra-args: "--results=verified,unknown"
```

The action automatically fails (exit code 183) when secrets are found, blocking merges.

### 4. Enable PR Comments

Help developers fix issues:

```yaml
with:
  post-pr-comment: "true"
```

### 5. Combine with Other Scans

Use alongside CodeQL and vulnerability scanning for comprehensive security.

## Detected Secret Types

TruffleHog detects 700+ secret types including:

- **Cloud Providers**: AWS, Azure, GCP credentials
- **Source Control**: GitHub, GitLab, Bitbucket tokens
- **Databases**: MongoDB, PostgreSQL connection strings
- **APIs**: Stripe, SendGrid, Twilio keys
- **CI/CD**: CircleCI, Travis CI tokens
- **Messaging**: Slack webhooks, Discord tokens
- **And many more...**

See [TruffleHog detectors](https://github.com/trufflesecurity/trufflehog#detectors) for complete list.

## Handling Found Secrets

If TruffleHog finds secrets:

### 1. Remove from Current Code

```bash
# Remove the secret
git commit -m "fix: remove leaked API key"
```

### 2. Revoke the Secret

- Rotate the credential immediately
- Revoke old API keys/tokens
- Generate new credentials

### 3. Clean Git History (If Needed)

For secrets in git history:

```bash
# Use git filter-repo or BFG Repo-Cleaner
git filter-repo --path-glob '**/*.env' --invert-paths
```

⚠️ **Warning**: Rewriting history requires force push and affects all collaborators.

### 4. Prevent Future Leaks

- Add secrets to `.gitignore`
- Use environment variables
- Use secret management tools (Vault, AWS Secrets Manager, etc.)
- Enable git hooks to scan before commit

## Note on Trivy

The `trivy-scan` action has been removed due to a supply chain compromise discovered in March 2026.
See: https://github.com/aquasecurity/trivy/discussions/10425

TruffleHog is now the sole secret scanning tool in this workflow.

## Version Pinning

### Use Specific Version (Recommended)

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@v1.0.0
```

### Use Major Version

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@v1
```

### Use Latest (Development)

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/trufflehog-scan@main
```

## References

- [TruffleHog Official Repository](https://github.com/trufflesecurity/trufflehog)
- [TruffleHog Documentation](https://github.com/trufflesecurity/trufflehog#usage)
- [Detected Secret Types](https://github.com/trufflesecurity/trufflehog#detectors)

## License

Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.

Licensed under the Apache License, Version 2.0.
