#!/usr/bin/env bash

set -euo pipefail

for command in yq jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'error: required command not found: %s\n' "$command" >&2
    exit 127
  fi
done

project_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
package_file="$project_root/packages/wazuh.yaml"

if [[ ! -f "$package_file" ]]; then
  printf 'error: package not found: %s\n' "$package_file" >&2
  exit 1
fi

mapfile -d '' yaml_files < <(
  find "$project_root" -type f \( -name '*.yaml' -o -name '*.yml' \) -print0
)

if ((${#yaml_files[@]} == 0)); then
  printf 'error: no YAML files found under %s\n' "$project_root" >&2
  exit 1
fi

for yaml_file in "${yaml_files[@]}"; do
  if ! yq '.' "$yaml_file" >/dev/null; then
    printf 'error: invalid YAML in %s\n' "$yaml_file" >&2
    exit 1
  fi
done

resource_count=$(yq '.rest | length' "$package_file")
if [[ "$resource_count" != "4" ]]; then
  printf 'error: expected 4 shared REST resources, found %s\n' "$resource_count" >&2
  exit 1
fi

payloads=$(yq -o=json \
  '[.rest[] | select(has("payload")) | .payload]' \
  "$package_file")
payload_count=$(jq 'length' <<<"$payloads")

if [[ "$payload_count" != "4" ]]; then
  printf 'error: expected 4 embedded JSON payloads, found %s\n' "$payload_count" >&2
  exit 1
fi

if ! jq -e 'map(fromjson) | all(.track_total_hits == true)' \
  <<<"$payloads" >/dev/null; then
  printf 'error: invalid JSON or track_total_hits is not true in every payload\n' >&2
  exit 1
fi

insecure_resource_count=$(
  yq '[.rest[] | select(.verify_ssl != true)] | length' "$package_file"
)
if [[ "$insecure_resource_count" != "0" ]]; then
  printf 'error: verify_ssl must be true for every REST resource\n' >&2
  exit 1
fi

unique_ids=$(
  for yaml_file in "${yaml_files[@]}"; do
    yq -r '.. | select(tag == "!!map" and has("unique_id")) | .unique_id' \
      "$yaml_file"
  done
)

duplicate_ids=$(sort <<<"$unique_ids" | uniq -d)
if [[ -n "$duplicate_ids" ]]; then
  printf 'error: duplicate unique_id values found:\n%s\n' "$duplicate_ids" >&2
  exit 1
fi

unique_id_count=$(grep -cve '^$' <<<"$unique_ids")
if [[ "$unique_id_count" != "19" ]]; then
  printf 'error: expected 19 unique entity IDs, found %s\n' "$unique_id_count" >&2
  exit 1
fi

printf 'validated %d YAML files, %d REST payloads, and %d unique entity IDs\n' \
  "${#yaml_files[@]}" "$payload_count" "$unique_id_count"
