# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-14

- Upgrade to Node 24 LTS from Node 16.

## [1.20.0] - 2026-01-02

- Add build-essential and python3-dev to the tools image.

## [1.19.0] - 2025-11-17

- Add Bazel multi-version support (VMAAS-708, NID-8024)
  - Bazel 6.5.0 (`bazel6` command) - for KubeVirt and projects requiring compatibility
  - Bazel 8.4.0 (`bazel8` command) - latest stable version
  - Default `bazel` symlink points to `bazel8`

## [1.18.0] - 2025-10-31

- Add make, update uv, ngc and nvvault.

## [1.17.0] - 2025-10-31

- CDS CLI 1.0.1

## [1.16.0] - 2025-10-30

- Add regctl tool to cds image

## [1.15.0] - 2025-10-06

- NGC CLI 4.5.2
- uv 0.8.23

## [1.14.1] - 2025-09-30

- Downgrade to go 1.24.3
- Pin the version of air-verse@v1.62.0
- Pin the version of delve@v1.25.2
- Pin the version of golangci-lint@v1.64.8
- Pin the version of goimports@v0.37.0
- Pin the version of swag@v1.16.4

## [1.14.0] - 2024-09-26

- Add git-lfs to the tools image.
- Upgrade ngc-cli to 3.169.4
- Upgrade to go 1.25.1 (air-verse@latest requires it)

## [1.13.1] - 2025-09-04

- fix: helm install script, using raw.githubusercontent.com instead of baltocdn.com

## [1.10.0] - 2024-06-05

- fix: upgrade ngc-cli to 3.151.0

## [1.9.1] - 2024-05-09

- fix docker builds

## [1.9.0] - 2024-05-05

- Upgrade `uv` to 0.7.2

## [1.8.1] - 2025-04-02

- Update uv to 0.6.11

## [1.8.0] - 2025-02-11

- Upgrade NGC CLI to 3.62.0
- Disable traces from NGC CLI

## [1.7.0] - 2025-02-04

- Remove Helm's `cm-push` plugin

## [1.6.0] - 2025-02-04

- Switch base image from `ubuntu:24.04` to `nvcr.io/nvidia/base/ubuntu:22.04_20240212`
- Updated most tools to more recent versions

## [1.5.0] - 2024-12-03

- Add `uv` and upgrade NGC CLI to 3.55.0

## [1.4.0] - 2024-11-11

- Upgrade NGC CLI to 3.53.0

## [1.3.0] - 2024-10-15

- Add terraform and terragrunt
- Remove unnecessary stages
- Pin more versions of tools

## [1.2.0] - 2024-10-02

- Upgrade NGC CLI to 3.50.0

## [1.1.0] - 2024-09-17

- Upgrade NGC CLI to 3.49.0

## [1.0.0] - 2024-08-21

- Initial Version
