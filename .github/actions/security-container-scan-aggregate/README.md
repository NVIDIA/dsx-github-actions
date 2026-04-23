# Security Container Scan Aggregate Action

A companion action to [`security-container-scan`](../security-container-scan/) that consolidates per-image Grype reports from an entire workflow run into a single summary table.

Follows the same pattern as `publish-test-results`: the individual scan jobs do not post their own summaries, and this aggregator runs once after all scans complete to produce:

- A single consolidated table in `$GITHUB_STEP_SUMMARY` on the aggregator job page
- (Optional) a sticky PR comment on `pull-request/NNN` branches created by copy-pr-bot

## When to use

- Your workflow scans **multiple images in one run** (typically via matrix or a fan-out of reusable workflow calls) and you want one summary per PR instead of one per image.
- You are OK with the per-image scan jobs *also* writing their own summary (the default of `security-container-scan`). If you do not want that, pass `write-summary: 'false'` to each `security-container-scan` invocation.

## Prerequisites

- Each upstream `security-container-scan` job must upload a per-image artifact whose name matches the pattern passed via `artifact-pattern` (default `grype-*`). The built-in convention is `grype-<service>-<run_id>-<run_attempt>`; the aggregator strips those trailing numeric segments to display a clean service name.
- Each artifact must contain `grype-results.json` at its root (this is what `security-container-scan` uploads by default).
- If `post-pr-comment: true` is used, the **caller job** must grant `pull-requests: write` permission. A default `GITHUB_TOKEN` is used unless an override is supplied via `github-token`.

## PR comment scope

This action only posts PR comments on push events that target the `pull-request/NNN` branch pattern produced by copy-pr-bot. The native `pull_request` event is intentionally **not** supported, matching the policy that all PR CI on these repos must be driven by copy-pr-bot.

On any other ref (`main`, tags, `feat/**`, `fix/**`, etc.) the PR-comment step is a no-op.

## Usage

```yaml
jobs:
  build-and-scan:
    # ... your per-service build job with security-container-scan ...

  container-scan-summary:
    name: Container Scan Summary
    needs: build-and-scan
    if: always()            # still summarise if some services failed
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write  # required for post-pr-comment: true
    steps:
      - uses: NVIDIA/dsx-github-actions/.github/actions/security-container-scan-aggregate@main
        with:
          post-pr-comment: 'true'
```

### Customising the artifact pattern

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/security-container-scan-aggregate@main
  with:
    artifact-pattern: 'scan-report-*'   # if your callers name artifacts differently
    post-pr-comment: 'true'
```

## Inputs

| Input              | Description                                                                                                                                                                                | Required | Default          |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | ---------------- |
| `artifact-pattern` | Glob pattern forwarded to `actions/download-artifact` to pick which artifacts to aggregate.                                                                                                | No       | `grype-*`        |
| `download-path`    | Directory the artifacts are downloaded into.                                                                                                                                               | No       | `.grype-aggregate` |
| `post-pr-comment`  | Post/update a sticky PR comment on copy-pr-bot `pull-request/NNN` branches. No-op on other refs.                                                                                           | No       | `false`          |
| `github-token`     | Token for listing, creating, and patching PR comments.                                                                                                                                     | No       | `${{ github.token }}` |

## Outputs

| Output         | Description                                                                     |
| -------------- | ------------------------------------------------------------------------------- |
| `summary-path` | Absolute path to the rendered markdown summary file on the runner.              |
| `pr-number`    | PR number extracted from a `pull-request/NNN` ref; empty string on other refs.  |

## Output format

Rendered table columns:

| Service | Total | Critical | High | Medium | Low | Other |

`Other` merges the `Negligible` and `Unknown` severity buckets so the main table stays narrow; detail lives in the per-service artifacts.

By design, the summary contains **only severity counts** — no CVE IDs, packages, or versions — to avoid turning a public workflow run into an attacker roadmap. Drill-down into the per-service `grype-*` artifact (JSON + SARIF) is collaborator-only.

## Sticky comment marker

The PR comment is marked with the HTML comment `<!-- grype-scan-summary -->` so successive runs on the same PR update the same comment in place rather than appending new ones. Do not include this marker in other bot comments on the same PR.
