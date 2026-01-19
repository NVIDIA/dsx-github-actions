# Changelog

All notable changes to CDS Containers will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.1] - 2026-01-19

### Added
- Initial GitHub version of CDS containers
- `cds-tools` container with Bazel 6.5.0 & 8.4.0, kubectl, helm, terraform, terragrunt, NGC CLI
- `cds-go-dev-1.24-alpine` container for Go development (Alpine-based, minimal size)
- `cds-go-dev-1.24-debian` container for Go development (Debian-based, better compatibility)
- `cds-grafana-backup-tool` container for Grafana backups
- GitHub Actions workflow for building and pushing to GHCR
- Version management via VERSION.md file
- Path-filtered pipeline (only triggers on cds-containers/ changes)
- Comprehensive documentation and usage examples

### Removed
- `nvault` (requires internal URM access, not available on GitHub runners)
- `cds-cli` (requires internal GitLab access, not available on GitHub runners)

### Changed
- Container registry from GitLab to GitHub Container Registry (GHCR)
- Image naming from `cds/cds-containers/*` to `nvidia/dsx-github-actions/cds-*`
- Version tagging from Git tags to VERSION.md file-based versioning
