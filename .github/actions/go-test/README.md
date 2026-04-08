# Go Test Action

A GitHub Composite Action that runs Go tests with race detection, coverage reporting, and JUnit XML output via `gotestsum`.

## Usage

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Go Test
    uses: NVIDIA/dsx-github-actions/.github/actions/go-test@main
```

### With custom packages and flags

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Go Test
    uses: NVIDIA/dsx-github-actions/.github/actions/go-test@main
    with:
      packages: './pkg/...'
      test-flags: '-v -count=1 -timeout=10m'
      go-flags: '-mod=vendor'
      artifact-name: 'test-results-${{ matrix.go-version }}'
```

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `go-version` | Go version to use (e.g., `1.25.5`). If empty, uses `go.mod`. | `false` | `''` |
| `go-version-file` | Path to `go.mod` for version detection. | `false` | `go.mod` |
| `working-directory` | Working directory for running tests. | `false` | `.` |
| `packages` | Go packages to test. | `false` | `./...` |
| `race` | Enable race detector. | `false` | `true` |
| `coverage` | Enable coverage reporting. | `false` | `true` |
| `coverage-file` | Coverage output file name. | `false` | `coverage.out` |
| `junit` | Generate JUnit XML report via `gotestsum`. | `false` | `true` |
| `junit-file` | JUnit XML output file name. | `false` | `junit-report.xml` |
| `test-flags` | Additional flags passed to `go test`. | `false` | `-v -count=1` |
| `go-flags` | `GOFLAGS` environment variable (e.g., `-mod=vendor`). | `false` | `''` |
| `gotestsum-version` | `gotestsum` version to install. | `false` | `v1.12.0` |
| `upload-artifacts` | Upload coverage and JUnit reports as workflow artifacts. | `false` | `true` |
| `artifact-name` | Name for uploaded artifact (override to avoid collisions in matrix builds). | `false` | `go-test-results` |

## Outputs

| Output | Description |
| :--- | :--- |
| `coverage-file` | Path to coverage output file. |
| `junit-file` | Path to JUnit XML report. |

## Behavior

1. **Set up Go** using `actions/setup-go` with caching enabled.
2. **Install gotestsum** (pinned version) if JUnit output is enabled.
3. **Run tests** with configurable race detection, coverage, and JUnit output.
4. **Display coverage summary** showing the total coverage percentage.
5. **Upload artifacts** (coverage and JUnit reports) with 7-day retention.

## Notes

- When using matrix builds, set `artifact-name` to a unique value per matrix cell to avoid upload collisions (e.g., `artifact-name: 'test-results-${{ matrix.go-version }}'`).
- All shell inputs are routed through environment variables to prevent expression injection.
