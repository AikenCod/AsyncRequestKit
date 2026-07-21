#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

for required_file in \
  docs/oss/EVIDENCE.md \
  docs/oss/application/qualification.txt \
  docs/oss/application/api-credit-use.txt \
  docs/oss/APPLICATION_REVIEW.md; do
  test -s "$required_file"
done

for material_file in docs/oss/application/*.txt; do
  count="$(python3 -c 'import pathlib,sys; print(len(pathlib.Path(sys.argv[1]).read_text().strip()))' "$material_file")"
  test "$count" -le 500
done

grep -q 'https://github.com/AikenCod/AsyncRequestKit' docs/oss/EVIDENCE.md
grep -q 'Observation date' docs/oss/EVIDENCE.md
! grep -Eqi 'guaranteed|widely adopted|industry-leading' docs/oss/application/*.txt
