# Helm Push NGC

Pushes a Helm Chart to NGC.

## Usage

```yaml
steps:
  - uses: actions/checkout@v4

  - name: Push Chart
    uses: NVIDIA/dsx-github-actions/.github/actions/helm-push-ngc@main
    with:
      package-dir: package
      ngc-key: ${{ secrets.NGC_API_KEY }}
      ngc-path: myorg/myteam
```

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `package-dir` | Directory of the .tgz artifact | No | package |
| `ngc-key` | NGC API Key | Yes | |
| `ngc-path` | NGC Org/Team path | Yes | |
| `ngc-duplicate` | Action for duplicate versions (skip/overwrite/fail) | No | skip |
| `ngc-registry` | NGC Registry URL | No | https://helm.ngc.nvidia.com/ |

## Outputs

| Output | Description |
| --- | --- |
| `chart-name` | The name of the chart |
| `chart-version` | The version of the chart |
| `push-skipped` | Whether the push was skipped |
