# Helm Package

Packages a Helm Chart.

## Usage

```yaml
steps:
  - uses: actions/checkout@v4

  - name: Package Chart
    uses: NVIDIA/dsx-github-actions/.github/actions/helm-package@main
    with:
      chart-path: ./charts/my-chart
      version: 1.0.0
      package-dir: build
```

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `chart-version` | Set the version of the Helm Chart | No | (from Chart.yaml) |
| `chart-version-suffix` | Set the version suffix | No | "" |
| `app-version` | Set the appVersion of the Helm Chart | No | (from Chart.yaml) |
| `chart-path` | Root directory for the Helm Chart | No | . |
| `package-dir` | Directory for the .tgz artifact | No | package |
| `lint` | Whether to lint before packaging | No | false |
| `extra-repos` | Extra repositories for packaging | No | [] |
