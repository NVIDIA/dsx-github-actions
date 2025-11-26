#!/usr/bin/env bash
set -euo pipefail

RED=${RED:-$'\033[91m'}
GREEN=${GREEN:-$'\033[92m'}
YELLOW=${YELLOW:-$'\033[93m'}
RESET=${RESET:-$'\033[0m'}

info() { printf '%s[INFO]%s %s\n' "$GREEN" "$RESET" "$1"; }
warn() { printf '%s[WARN]%s %s\n' "$YELLOW" "$RESET" "$1"; }
error() { printf '%s[ERROR]%s %s\n' "$RED" "$RESET" "$1" >&2; }

require_env() {
  local name=$1
  if [[ -z "${!name:-}" ]]; then
    error "$name is required"
    exit 1
  fi
}

PUSH_RESULT_FILE=${PUSH_RESULT_FILE:-${RUNNER_TEMP:-/tmp}/ngc-push-result}
mkdir -p "$(dirname "$PUSH_RESULT_FILE")"

write_result() {
  printf 'resource-id=%s\nupload-status=%s\n' "$1" "$2" > "$PUSH_RESULT_FILE"
}

require_env CC_RESOURCE_NAME
require_env CC_RESOURCE_DISPLAY_NAME
require_env CC_RESOURCE_DESCRIPTION
require_env CC_RESOURCE_PATH
require_env CC_RESOURCE_VERSION
require_env CC_RESOURCE_FORMAT
require_env CC_RESOURCE_APPLICATION
require_env CC_RESOURCE_FRAMEWORK
require_env CC_RESOURCE_PRECISION
require_env CC_RESOURCE_NGC_FORCE
require_env CC_RESOURCE_NGC_PATH
require_env CC_RESOURCE_NGC_KEY

if ! command -v ngc >/dev/null 2>&1; then
  error "ngc CLI is not available"
  exit 1
fi

export NGC_CLI_API_KEY="$CC_RESOURCE_NGC_KEY"
unset NGC_API_KEY
IFS='/' read -r NGC_CLI_ORG NGC_CLI_TEAM <<< "$CC_RESOURCE_NGC_PATH"
if [[ -z "$NGC_CLI_ORG" ]]; then NGC_CLI_ORG="no-org"; fi
if [[ -z "$NGC_CLI_TEAM" ]]; then NGC_CLI_TEAM="no-team"; fi
export NGC_CLI_ORG NGC_CLI_TEAM

resource_fqn="$CC_RESOURCE_NGC_PATH/$CC_RESOURCE_NAME"
resource_id="$resource_fqn:$CC_RESOURCE_VERSION"

info "Using resource $resource_fqn"

resource_exists=false
if ngc registry resource info "$resource_fqn" >/dev/null 2>&1; then
  resource_exists=true
  info "Resource already exists. Updating metadata."
  subcommand="update"
else
  info "Resource not found. Creating a new one."
  subcommand="create"
fi

ngc registry resource "$subcommand" \
  --display-name "$CC_RESOURCE_DISPLAY_NAME" \
  --short-desc "$CC_RESOURCE_DESCRIPTION" \
  --application "$CC_RESOURCE_APPLICATION" \
  --framework "$CC_RESOURCE_FRAMEWORK" \
  --format "$CC_RESOURCE_FORMAT" \
  --precision "$CC_RESOURCE_PRECISION" \
  "$resource_fqn"

version_exists=false
if ngc registry resource info "$resource_id" >/dev/null 2>&1; then
  version_exists=true
fi

if [[ "$version_exists" == true ]]; then
  case "$CC_RESOURCE_NGC_FORCE" in
    skip)
      warn "Resource version already exists. Skipping upload."
      write_result "$resource_id" "skipped"
      exit 66
      ;;
    fail)
      error "Resource version already exists and ngc-force=fail."
      exit 1
      ;;
    overwrite)
      warn "Resource version exists. Removing for overwrite."
      ngc registry resource remove -y "$resource_id"
      ;;
  esac
fi

ngc registry resource upload-version --source "$CC_RESOURCE_PATH" "$resource_id"

if [[ "$version_exists" == true && "$CC_RESOURCE_NGC_FORCE" == "overwrite" ]]; then
  final_status="overwritten"
elif [[ "$resource_exists" == true ]]; then
  final_status="updated"
else
  final_status="created"
fi

write_result "$resource_id" "$final_status"
info "Finished uploading $resource_id"
