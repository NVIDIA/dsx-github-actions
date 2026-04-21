#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2026 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

image="${INPUT_IMAGE:-}"
raw_tags="${INPUT_TAGS:-}"
cache_enabled="${INPUT_CACHE_ENABLED:-true}"
cache_scope_input="${INPUT_CACHE_SCOPE:-}"

if [[ -z "${image}" ]]; then
  echo "ERROR: input 'image' is required." >&2
  exit 2
fi

short_sha=""
if [[ -n "${GITHUB_SHA:-}" ]]; then
  short_sha="${GITHUB_SHA:0:7}"
fi

default_tag="sha-${short_sha:-unknown}"

normalize_list() {
  # turns commas into newlines, trims whitespace, removes empty lines
  echo "$1" \
    | tr ',' '\n' \
    | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
    | sed '/^$/d'
}

is_full_ref() {
  # very lightweight detection for fully qualified image refs:
  # - contains '@' (digest reference)
  # - OR contains '/' and ':' (registry/repo + tag)
  local t="$1"
  if [[ "$t" == *@* ]]; then
    return 0
  fi
  if [[ "$t" == */* && "$t" == *:* ]]; then
    return 0
  fi
  return 1
}

tags_list="$(normalize_list "${raw_tags}")"
if [[ -z "${tags_list}" ]]; then
  tags_list="${default_tag}"
fi

normalized_refs=""
while IFS= read -r t; do
  if is_full_ref "${t}"; then
    normalized_refs+="${t}"$'\n'
  else
    normalized_refs+="${image}:${t}"$'\n'
  fi
done <<< "${tags_list}"

# trim trailing newline
normalized_refs="$(printf "%s" "${normalized_refs}" | sed '/^$/d')"

cache_scope="${cache_scope_input}"
if [[ -z "${cache_scope}" ]]; then
  cache_scope="$(echo "${image}" | tr '/:@' '---' | tr -cs 'a-zA-Z0-9._-' '-')"
  cache_scope="${cache_scope%-}"
fi

cache_from=""
cache_to=""
if [[ "${cache_enabled}" == "true" ]]; then
  cache_from="type=gha,scope=${cache_scope}"
  cache_to="type=gha,mode=max,scope=${cache_scope}"
fi

{
  echo "tags<<EOF"
  echo "${normalized_refs}"
  echo "EOF"
  echo "cache-scope=${cache_scope}"
  echo "cache-from=${cache_from}"
  echo "cache-to=${cache_to}"
} >> "${GITHUB_OUTPUT}"
