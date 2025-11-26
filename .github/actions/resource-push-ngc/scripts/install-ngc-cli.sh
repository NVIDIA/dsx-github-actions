#!/usr/bin/env bash
set -euo pipefail

RED=${RED:-$'\033[91m'}
GREEN=${GREEN:-$'\033[92m'}
YELLOW=${YELLOW:-$'\033[93m'}
RESET=${RESET:-$'\033[0m'}

log_info() { printf '%s[INFO]%s %s\n' "$GREEN" "$RESET" "$1"; }
log_warn() { printf '%s[WARN]%s %s\n' "$YELLOW" "$RESET" "$1"; }
log_error() { printf '%s[ERROR]%s %s\n' "$RED" "$RESET" "$1"; }

if command -v ngc >/dev/null 2>&1; then
  log_info "NGC CLI already available, skipping installation."
  exit 0
fi

download_url="https://download.nvidia.com/ngc/ngccli_linux.zip"

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

log_info "Downloading NGC CLI from $download_url"
curl -sSfL "$download_url" -o "$work_dir/ngccli.zip"
unzip -q "$work_dir/ngccli.zip" -d "$work_dir"

extract_dir=$(find "$work_dir" -maxdepth 2 -type d -name 'ngc-cli*' | head -n 1)
if [[ -z "$extract_dir" ]]; then
  log_error "Failed to locate extracted ngc-cli directory"
  exit 1
fi

bin_path=$(find "$extract_dir" -maxdepth 2 -type f -name 'ngc*' | head -n 1)
if [[ -z "$bin_path" ]]; then
  log_error "Unable to find ngc executable"
  exit 1
fi

install_root="$HOME/.local/bin"
mkdir -p "$install_root"
cp "$bin_path" "$install_root/ngc"
chmod +x "$install_root/ngc"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "$install_root" >> "$GITHUB_PATH"
else
  export PATH="$install_root:$PATH"
fi

log_info "NGC CLI installed at $install_root/ngc"
ngc --version
