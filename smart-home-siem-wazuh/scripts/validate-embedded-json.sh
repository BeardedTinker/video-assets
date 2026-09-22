#!/usr/bin/env bash

set -euo pipefail

for command in yq jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'error: required command not found: %s\n' "$command" >&2
    exit 127
  fi
done

project_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
mapfile -d '' yaml_files < <(
  find "$project_root" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0
)

if ((${#yaml_files[@]} == 0)); then
  printf 'error: no YAML files found under %s\n' "$project_root" >&2
  exit 1
fi

payload_count=0
for yaml_file in "${yaml_files[@]}"; do
  payloads=$(yq -o=json \
    '[.. | select(tag == "!!map" and has("payload")) | .payload]' \
    "$yaml_file")
  count=$(jq 'length' <<<"$payloads")

  if ! jq -e 'map(fromjson) | true' <<<"$payloads" >/dev/null; then
    printf 'error: invalid embedded JSON payload in %s\n' "$yaml_file" >&2
    exit 1
  fi

  payload_count=$((payload_count + count))
done

if ((payload_count == 0)); then
  printf 'error: no embedded payload values found under %s\n' "$project_root" >&2
  exit 1
fi

printf 'validated %d embedded JSON payloads across %d YAML files\n' \
  "$payload_count" "${#yaml_files[@]}"
