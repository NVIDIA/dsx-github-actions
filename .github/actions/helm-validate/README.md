# Helm Validate

Validates a Helm Chart using lint and template commands.

## Usage

```yaml
steps:
  - uses: actions/checkout@v4

  - name: Validate Chart
    uses: NVIDIA/dsx-github-actions/.github/actions/helm-validate@main
    with:
      chart-path: ./charts/my-chart
      valueOverrides: |
        global.env=prod
        image.tag=v1.0.0
      extra-repos: |
        bitnami https://charts.bitnami.com/bitnami
```

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `chart-path` | Root directory for the Helm Chart | No | . |
| `lint` | Whether to lint the Helm Chart | No | true |
| `template` | Whether to template the Helm Chart | No | true |
| `extra-repos` | Extra repositories (JSON or "name url" per line) | No | [] |
| `valueOverrides` | Value overrides (JSON list or "key=value" list) | No | [] |
