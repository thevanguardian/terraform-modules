#!/usr/bin/env bash
set -euo pipefail

changed_tf=$(git diff --cached --name-only --diff-filter=ACMRTUXB | grep -E '\.tf$' || true)

if [[ -z "${changed_tf}" ]]; then
  exit 0
fi

declare -A unique_dirs=()
while IFS= read -r file; do
  [[ -z "${file}" ]] && continue
  dir=$(dirname "${file}")
  unique_dirs["${dir}"]=1
done <<< "${changed_tf}"

for dir in "${!unique_dirs[@]}"; do
  [[ -d "${dir}" ]] || continue
  terraform fmt "${dir}"
done
