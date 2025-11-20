#!/usr/bin/env bash
set -euo pipefail

changed_files=$(git diff --cached --name-only --diff-filter=ACMRTUXB | grep -E '(README\.md|\.tf)$' || true)

if [[ -z "${changed_files}" ]]; then
  exit 0
fi

unique_dirs=$(printf '%s\n' "${changed_files}" | xargs -r -n1 dirname | sort -u)

for dir in ${unique_dirs}; do
  readme_path="${dir}/README.md"
  [[ -f "${readme_path}" ]] || continue

  args=(markdown . --output-file README.md --output-mode inject)

  (
    cd "${dir}"
    terraform-docs "${args[@]}"
  )
done
