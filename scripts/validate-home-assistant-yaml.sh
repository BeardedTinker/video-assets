#!/usr/bin/env bash

set -euo pipefail

for command in git yq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf 'error: required command not found: %s\n' "$command" >&2
    exit 127
  fi
done

project_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || fail "validator must be stored inside a Git work tree: $project_root"

automation_rule='map(
  (tag == "!!map")
  and has("id")
  and ((.id | tag) == "!!str")
  and ((.id | length) > 0)
  and has("alias")
  and (has("trigger") or has("triggers"))
  and (has("action") or has("actions"))
) | all'

mapfile -d '' yaml_files < <(git ls-files -z -- '*.yaml' '*.yml')
mapfile -d '' automation_files < <(
  git ls-files -z -- '*/automations/*.yaml' '*/automations/*.yml'
)
mapfile -d '' package_files < <(
  git ls-files -z -- '*/packages/*.yaml' '*/packages/*.yml'
)

((${#yaml_files[@]} > 0)) || fail 'no tracked YAML files found'

automation_count=0
for file in "${automation_files[@]}"; do
  root_tag=$(yq -r 'tag' "$file")
  case "$root_tag" in
    '!!seq')
      (($(yq -r 'length' "$file") > 0)) \
        || fail "automation list is empty: $file"
      yq --exit-status "$automation_rule" "$file" >/dev/null \
        || fail "automation list entries require non-empty id, alias, trigger(s), and action(s): $file"
      automation_count=$((automation_count + $(yq -r 'length' "$file")))
      ;;
    '!!map')
      yq --exit-status '
        has("alias")
        and (has("trigger") or has("triggers"))
        and (has("action") or has("actions"))
      ' "$file" >/dev/null \
        || fail "automation requires alias, trigger(s), and action(s): $file"
      automation_count=$((automation_count + 1))
      ;;
    *)
      fail "automation root must be a mapping or sequence: $file"
      ;;
  esac
done

package_automation_count=0
for file in "${package_files[@]}"; do
  [[ $(yq -r 'tag' "$file") == '!!map' ]] \
    || fail "package root must be a mapping: $file"

  if [[ $(yq -r '.automation | tag' "$file") == '!!null' ]]; then
    continue
  fi

  [[ $(yq -r '.automation | tag' "$file") == '!!seq' ]] \
    || fail "package automation section must be a sequence: $file"
  (($(yq -r '.automation | length' "$file") > 0)) \
    || fail "package automation section is empty: $file"
  yq --exit-status ".automation | $automation_rule" "$file" >/dev/null \
    || fail "package automations require non-empty id, alias, trigger(s), and action(s): $file"
  package_automation_count=$((
    package_automation_count + $(yq -r '.automation | length' "$file")
  ))
done

declare -A projects=()
for file in "${yaml_files[@]}"; do
  if [[ $file == */* && $file != .* ]]; then
    projects["${file%%/*}"]=1
  fi
done

for project in "${!projects[@]}"; do
  project_unique_ids=()
  project_automation_ids=()

  for file in "${yaml_files[@]}"; do
    [[ $file == "$project/"* ]] || continue
    yq --exit-status '[
      .. | select(tag == "!!map" and has("unique_id")) | .unique_id
      | select((tag != "!!str") or (length == 0))
    ] | length == 0' "$file" >/dev/null \
      || fail "unique_id values must be non-empty strings: $file"
    mapfile -t file_unique_ids < <(
      yq -r '.. | select(tag == "!!map" and has("unique_id")) | .unique_id' "$file"
    )
    project_unique_ids+=("${file_unique_ids[@]}")
  done

  for file in "${automation_files[@]}"; do
    [[ $file == "$project/"* ]] || continue
    if [[ $(yq -r 'tag' "$file") == '!!seq' ]]; then
      mapfile -t file_automation_ids < <(yq -r '.[].id' "$file")
    else
      mapfile -t file_automation_ids < <(yq -r 'select(has("id")) | .id' "$file")
    fi
    project_automation_ids+=("${file_automation_ids[@]}")
  done

  for file in "${package_files[@]}"; do
    [[ $file == "$project/"* ]] || continue
    if [[ $(yq -r '.automation | tag' "$file") == '!!seq' ]]; then
      mapfile -t file_automation_ids < <(yq -r '.automation[].id' "$file")
      project_automation_ids+=("${file_automation_ids[@]}")
    fi
  done

  if ((${#project_unique_ids[@]} > 0)); then
    duplicates=$(printf '%s\n' "${project_unique_ids[@]}" | sort | uniq -d)
    [[ -z $duplicates ]] \
      || fail "duplicate unique_id values in $project: ${duplicates//$'\n'/, }"
  fi

  if ((${#project_automation_ids[@]} > 0)); then
    duplicates=$(printf '%s\n' "${project_automation_ids[@]}" | sort | uniq -d)
    [[ -z $duplicates ]] \
      || fail "duplicate automation id values in $project: ${duplicates//$'\n'/, }"
  fi
done

printf 'validated %d automation files, %d standalone automations, %d package files, and %d package automations\n' \
  "${#automation_files[@]}" "$automation_count" "${#package_files[@]}" "$package_automation_count"
