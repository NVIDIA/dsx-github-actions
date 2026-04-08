# License Headers Action

A GitHub Composite Action that checks (and optionally adds) SPDX license headers using `addlicense`.

## Usage

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Check License Headers
    uses: NVIDIA/dsx-github-actions/.github/actions/license-headers@main
```

### Auto-add missing headers

```yaml
steps:
  - uses: actions/checkout@v4
  - name: Add License Headers
    uses: NVIDIA/dsx-github-actions/.github/actions/license-headers@main
    with:
      check-only: 'false'
      paths: 'src/ pkg/ cmd/'
      ignore: 'vendor/**,testdata/**'
```

## Inputs

| Input | Description | Required | Default |
| :--- | :--- | :--- | :--- |
| `license` | License type (`apache`, `mit`, `bsd`). | `false` | `apache` |
| `copyright-holder` | Copyright holder string. | `false` | `NVIDIA CORPORATION & AFFILIATES. All rights reserved.` |
| `year` | Copyright year. | `false` | `2026` |
| `paths` | Space-separated paths to check. | `false` | `.` |
| `ignore` | Comma-separated glob patterns to ignore. | `false` | `vendor/**` |
| `check-only` | Only check headers (fail if missing). Set to `false` to auto-add. | `false` | `true` |
| `addlicense-version` | `addlicense` tool version. | `false` | `v1.2.0` |
| `go-version` | Go version for installing `addlicense`. If empty, uses existing Go. | `false` | `''` |

## Behavior

1. **Set up Go** (optional, only if `go-version` is specified).
2. **Install addlicense** at the pinned version.
3. **Check or add** license headers depending on the `check-only` flag.
   - Check mode: fails if any files are missing headers.
   - Add mode: automatically inserts missing headers.
