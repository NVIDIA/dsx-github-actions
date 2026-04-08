# Semantic Release Action

A composite GitHub Action that wraps [cycjimmy/semantic-release-action](https://github.com/cycjimmy/semantic-release-action) to provide automated versioning and package publishing using [semantic-release](https://github.com/semantic-release/semantic-release).

## Features

- ✅ **Automated Versioning**: Determines version bumps based on conventional commits
- ✅ **Changelog Generation**: Automatically generates CHANGELOG.md
- ✅ **Git Tags**: Creates and pushes semantic version tags
- ✅ **GitHub Releases**: Publishes releases with release notes
- ✅ **Conventional Commits**: Follows [Conventional Commits](https://www.conventionalcommits.org/) specification
- ✅ **Flexible Configuration**: Supports branches, plugins, and custom workflows
- ✅ **Dry-Run Mode**: Test releases without publishing

## Quick Start

### Basic Usage

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write # Required for creating releases and tags
      issues: write # Required for commenting on issues
      pull-requests: write # Required for commenting on PRs
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Required for semantic-release

      - uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

## How It Works

### Conventional Commits

Semantic-release analyzes your commit messages to determine the next version:

| Commit Type            | Version Bump  | Example                                |
| ---------------------- | ------------- | -------------------------------------- |
| `fix:`                 | Patch (0.0.x) | `fix: resolve memory leak`             |
| `feat:`                | Minor (0.x.0) | `feat: add new API endpoint`           |
| `BREAKING CHANGE:`     | Major (x.0.0) | `feat!: redesign public API`           |
| `perf:`, `docs:`, etc. | No release    | Documentation/performance improvements |

**Example Commits:**

```bash
# Patch release (1.0.0 → 1.0.1)
git commit -m "fix: resolve null pointer exception"

# Minor release (1.0.0 → 1.1.0)
git commit -m "feat: add user authentication"

# Major release (1.0.0 → 2.0.0)
git commit -m "feat!: redesign API

BREAKING CHANGE: API endpoints have changed"
```

### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Common types:**

- `feat`: New feature (minor version bump)
- `fix`: Bug fix (patch version bump)
- `docs`: Documentation changes (no release)
- `style`: Code style changes (no release)
- `refactor`: Code refactoring (no release)
- `perf`: Performance improvements (patch version bump)
- `test`: Adding tests (no release)
- `chore`: Maintenance tasks (no release)
- `ci`: CI/CD changes (no release)

## Inputs

| Input               | Description                               | Required | Default               |
| ------------------- | ----------------------------------------- | -------- | --------------------- |
| `semantic-version`  | Semantic-release version to use           | No       | Latest                |
| `extra-plugins`     | Extra plugins to install (one per line)   | No       | `''`                  |
| `dry-run`           | Run in dry-run mode (no releases created) | No       | `false`               |
| `branches`          | Branches configuration (JSON array)       | No       | `''`                  |
| `tag-format`        | Git tag format                            | No       | `v${version}`         |
| `extends`           | Shareable configurations to extend        | No       | `''`                  |
| `working-directory` | Working directory for semantic-release    | No       | `.`                   |
| `ci`                | Run with CI support                       | No       | `true`                |
| `github-token`      | GitHub token for creating releases        | No       | `${{ github.token }}` |

## Outputs

| Output                      | Description                                      |
| --------------------------- | ------------------------------------------------ |
| `new-release-published`     | Whether a new release was published (true/false) |
| `new-release-version`       | Version of the new release (e.g., 1.3.0)         |
| `new-release-major-version` | Major version (e.g., 1)                          |
| `new-release-minor-version` | Minor version (e.g., 3)                          |
| `new-release-patch-version` | Patch version (e.g., 0)                          |
| `new-release-channel`       | Distribution channel                             |
| `new-release-notes`         | Release notes                                    |
| `new-release-git-head`      | Git SHA of the new release                       |
| `new-release-git-tag`       | Git tag (e.g., v1.3.0)                           |
| `last-release-version`      | Previous release version                         |
| `last-release-git-head`     | Git SHA of previous release                      |
| `last-release-git-tag`      | Git tag of previous release                      |

## Required Permissions

```yaml
permissions:
  contents: write # Create releases and tags
  issues: write # Comment on released issues
  pull-requests: write # Comment on released PRs
```

## Configuration

Create a `.releaserc.json` or `.releaserc.yml` file in your repository root:

### Basic Configuration

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/github"
  ]
}
```

### Configuration with Changelog

```json
{
  "branches": ["main", "next"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    "@semantic-release/github",
    "@semantic-release/git"
  ]
}
```

## Examples

### Example 1: Basic Release

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
```

### Example 2: With Changelog Generation

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
  with:
    extra-plugins: |
      @semantic-release/changelog@7.0.0
      @semantic-release/git@10.0.0
```

**Configuration (.releaserc.json):**

```json
{
  "branches": ["main"],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    [
      "@semantic-release/git",
      {
        "assets": ["CHANGELOG.md"],
        "message": "chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}"
      }
    ],
    "@semantic-release/github"
  ]
}
```

### Example 3: Multi-Branch Strategy

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
  with:
    branches: |
      [
        "main",
        {"name": "next", "prerelease": true},
        {"name": "beta", "prerelease": true}
      ]
```

### Example 4: Monorepo with Custom Tag Format

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
  with:
    working-directory: ./packages/my-package
    tag-format: my-package-v${version}
```

### Example 5: Dry-Run for Pull Requests

```yaml
name: Test Release

on:
  pull_request:

jobs:
  test-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
        with:
          dry-run: "true"
          ci: "false"
```

### Example 6: Using Output Variables

```yaml
steps:
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0

  - name: Run Semantic Release
    id: release
    uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main

  - name: Deploy New Version
    if: steps.release.outputs.new-release-published == 'true'
    run: |
      echo "Deploying version ${{ steps.release.outputs.new-release-version }}"
      ./deploy.sh ${{ steps.release.outputs.new-release-version }}

  - name: Notify Slack
    if: steps.release.outputs.new-release-published == 'true'
    run: |
      curl -X POST ${{ secrets.SLACK_WEBHOOK }} \
        -d "New release: v${{ steps.release.outputs.new-release-version }}"
```

### Example 7: NPM Package Publishing

```yaml
- uses: actions/setup-node@53b83947a5a98c8d113130e565377fae1a50d02f # v6.3.0
  with:
    node-version: "20"

- uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
  with:
    extra-plugins: "@semantic-release/npm@12.0.0"
  env:
    NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

**Configuration (.releaserc.json):**

```json
{
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/npm",
    "@semantic-release/github"
  ]
}
```

## Common Plugins

### @semantic-release/changelog

Generates a CHANGELOG.md file:

```yaml
extra-plugins: "@semantic-release/changelog@7.0.0"
```

### @semantic-release/git

Commits assets (like CHANGELOG.md) back to the repository:

```yaml
extra-plugins: "@semantic-release/git@10.0.0"
```

### @semantic-release/npm

Publishes to npm registry:

```yaml
extra-plugins: "@semantic-release/npm@12.0.0"
```

### @semantic-release/exec

Executes custom scripts:

```yaml
extra-plugins: "@semantic-release/exec@6.0.0"
```

## Troubleshooting

### No Release Created

**Issue**: Semantic-release doesn't create a release.

**Solutions**:

1. Ensure commits follow conventional commit format
2. Check that you're on the correct branch (default: `main`)
3. Verify permissions are set correctly
4. Use `dry-run: "true"` to see what would happen

### Permission Denied

**Issue**: Error creating releases or tags.

**Solution**: Ensure the job has required permissions:

```yaml
permissions:
  contents: write
  issues: write
  pull-requests: write
```

### GITHUB_TOKEN has insufficient permissions

**Issue**: Default token doesn't have enough permissions.

**Solution**: Use a Personal Access Token (PAT):

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
  with:
    github-token: ${{ secrets.SEMANTIC_RELEASE_TOKEN }}
```

### Plugin Not Found

**Issue**: Extra plugin not installed.

**Solution**: Specify version and add to both `extra-plugins` and `.releaserc.json`:

```yaml
extra-plugins: |
  @semantic-release/changelog@7.0.0
  @semantic-release/git@10.0.0
```

## Best Practices

### 1. Use Conventional Commits

Enforce conventional commits with a commit linter:

**.commitlintrc.json:**

```json
{
  "extends": ["@commitlint/config-conventional"]
}
```

**package.json:**

```json
{
  "husky": {
    "hooks": {
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS"
    }
  }
}
```

### 2. Protect Main Branch

Configure branch protection rules:

- Require pull request reviews
- Require status checks to pass
- Require conventional commit messages

### 3. Skip CI for Release Commits

Add `[skip ci]` to release commits to avoid infinite loops:

```json
{
  "plugins": [
    [
      "@semantic-release/git",
      {
        "message": "chore(release): ${nextRelease.version} [skip ci]"
      }
    ]
  ]
}
```

### 4. Use Dry-Run for Testing

Test your semantic-release configuration in PRs:

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/semantic-release@main
  with:
    dry-run: "true"
```

### 5. Version Lock Plugins

Always specify plugin versions to prevent breaking changes:

```yaml
extra-plugins: |
  @semantic-release/changelog@7.0.0
  @semantic-release/git@10.0.0
```

## References

- [Semantic Release Documentation](https://semantic-release.gitbook.io/semantic-release/)
- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [cycjimmy/semantic-release-action](https://github.com/cycjimmy/semantic-release-action)
- [Semantic Release Plugins](https://semantic-release.gitbook.io/semantic-release/extending/plugins-list)

## License

Copyright (c) 2025, NVIDIA CORPORATION. All rights reserved.

Licensed under the Apache License, Version 2.0.
