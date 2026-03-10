# Stale Issues and PRs Action

A composite GitHub Action that wraps [actions/stale](https://github.com/actions/stale) to automatically mark inactive issues and pull requests as stale and eventually close them. This keeps the issue tracker focused on active work.

## How It Works

```
Issue opened ──► 60 days idle ──► Labeled "lifecycle/stale" ──► 14 more days ──► Closed
PR opened    ──► 30 days idle ──► Labeled "lifecycle/stale" ──► 14 more days ──► Closed
```

### Default Exemptions

| Label | Effect |
| --- | --- |
| `lifecycle/frozen` | Never marked stale (issues and PRs) |
| `priority/critical` | Never marked stale (issues only) |
| `good first issue` | Never marked stale (issues only) |
| `do-not-merge` | Never marked stale (PRs only) |

## Quick Start

```yaml
name: Stale Issues and PRs

on:
  schedule:
    - cron: "0 6 * * *"  # Daily at 6am UTC
  workflow_dispatch: {}

permissions:
  contents: read

jobs:
  stale:
    name: Mark stale issues and PRs
    runs-on: ubuntu-latest
    permissions:
      issues: write
      pull-requests: write
    timeout-minutes: 10
    steps:
      - uses: NVIDIA/dsx-github-actions/.github/actions/stale-check@main
```

All inputs have sensible defaults, so zero configuration is needed to get started.

## Usage

### Custom Timelines

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/stale-check@main
  with:
    days-before-issue-stale: '90'
    days-before-pr-stale: '45'
    days-before-close: '7'
```

### Custom Exempt Labels

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/stale-check@main
  with:
    exempt-issue-labels: 'lifecycle/frozen,priority/critical,epic'
    exempt-pr-labels: 'lifecycle/frozen,do-not-merge,wip'
```

### Custom Messages

```yaml
- uses: NVIDIA/dsx-github-actions/.github/actions/stale-check@main
  with:
    stale-issue-message: |
      This issue has been inactive for 60 days and will be closed soon.
      Please comment to keep it open.
    stale-pr-message: |
      This PR has been inactive for 30 days and will be closed soon.
      Please push commits or comment to keep it open.
```

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `days-before-issue-stale` | Days of inactivity before an issue is marked stale | No | `60` |
| `days-before-pr-stale` | Days of inactivity before a PR is marked stale | No | `30` |
| `days-before-close` | Days after stale label before closing | No | `14` |
| `stale-issue-label` | Label to apply to stale issues | No | `lifecycle/stale` |
| `stale-pr-label` | Label to apply to stale PRs | No | `lifecycle/stale` |
| `exempt-issue-labels` | Comma-separated labels that exempt issues from being marked stale | No | `lifecycle/frozen,priority/critical,good first issue` |
| `exempt-pr-labels` | Comma-separated labels that exempt PRs from being marked stale | No | `lifecycle/frozen,do-not-merge` |
| `stale-issue-message` | Message posted when an issue is marked stale | No | *(see default below)* |
| `stale-pr-message` | Message posted when a PR is marked stale | No | *(see default below)* |
| `close-issue-message` | Message posted when a stale issue is closed | No | *(see default below)* |
| `close-pr-message` | Message posted when a stale PR is closed | No | *(see default below)* |
| `operations-per-run` | Maximum number of operations per run (API budget) | No | `500` |

### Default Messages

**Stale issue message:**

> This issue has been marked as stale due to 60 days of inactivity.
> It will be closed in 14 days unless there is new activity.
>
> To keep this issue open:
>
> - Add a comment with an update
> - Add the `lifecycle/frozen` label
>
> If this issue is no longer relevant, it's okay to let it close.

**Stale PR message:**

> This PR has been marked as stale due to 30 days of inactivity.
> It will be closed in 14 days unless there is new activity.
>
> To keep this PR open:
>
> - Push new commits or add a comment
> - Add the `lifecycle/frozen` label
>
> If this work is no longer needed, it's okay to let it close.

**Close issue message:**

> This issue was automatically closed due to inactivity after being marked as stale.
>
> If you believe this issue is still relevant:
>
> - Reopen with a comment providing updated details or context
> - Add the `lifecycle/frozen` label to prevent it from being closed again

**Close PR message:**

> This pull request was automatically closed due to inactivity after being marked as stale.
>
> If you would like to continue this work:
>
> - Reopen and push new commits or add a comment with an update
> - Add the `lifecycle/frozen` label to prevent it from being closed again

## Required Permissions

The calling workflow job must have:

```yaml
permissions:
  issues: write
  pull-requests: write
```

## Recommended Labels

Create these labels in your repository for full functionality:

| Label | Description | Color suggestion |
| --- | --- | --- |
| `lifecycle/stale` | Automatically applied to inactive issues/PRs | `#795548` |
| `lifecycle/frozen` | Prevents an issue/PR from being marked stale | `#0d47a1` |
| `priority/critical` | Exempts issues from stale checks | `#d32f2f` |
| `do-not-merge` | Exempts PRs from stale checks | `#b71c1c` |

## Version Pinning

### Use Specific Version (Recommended for Production)

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/stale-check@v1.0.0
```

### Use Latest (Development/Testing)

```yaml
uses: NVIDIA/dsx-github-actions/.github/actions/stale-check@main
```

## License

Copyright (c) 2026, NVIDIA CORPORATION. All rights reserved.

Licensed under the Apache License, Version 2.0.
