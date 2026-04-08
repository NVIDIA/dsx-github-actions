# Go Lint Action

A GitHub Composite Action that runs a Go linting suite: `golangci-lint`, `go fmt` check, and `go vet`.

## Usage

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Go Lint
    uses: NVIDIA/dsx-github-actions/.github/actions/go-lint@main
    with:
      working-directory: '.'
```

### With vendor mode and custom config

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Go Lint
    uses: NVIDIA/dsx-github-actions/.github/actions/go-lint@main
    with:
      go-flags: '-mod=vendor'
      config-path: '.golangci.yml'
      golangci-lint-args: '--timeout=5m'
```

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `go-version` | Go version to use (e.g., `1.25.5`). If empty, uses `go.mod`. | `false` | `''` |
| `go-version-file` | Path to `go.mod` for version detection. | `false` | `go.mod` |
| `working-directory` | Working directory for lint commands. | `false` | `.` |
| `golangci-lint-version` | golangci-lint version. | `false` | `v2.11` |
| `golangci-lint-args` | Additional arguments for `golangci-lint run`. | `false` | `''` |
| `config-path` | Path to `.golangci.yml` config file. | `false` | `''` |
| `go-flags` | `GOFLAGS` environment variable (e.g., `-mod=vendor`). | `false` | `''` |

## Behavior

1. **Set up Go** using `actions/setup-go` with caching enabled.
2. **Check go fmt** by running `gofmt -l` on all `.go` files (excluding `vendor/`). Fails if any files are unformatted.
3. **Run go vet** on all packages.
4. **Run golangci-lint** via `golangci/golangci-lint-action`.
