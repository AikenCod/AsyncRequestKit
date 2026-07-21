#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

missing=0
while IFS= read -r -d '' file; do
  if grep -Eq 'URL(Request|Session|Response)|HTTPURLResponse|URLComponents|URLQueryItem' "$file"; then
    if ! grep -q '#if canImport(FoundationNetworking)' "$file" ||
       ! grep -q '^import FoundationNetworking$' "$file"; then
      echo "missing FoundationNetworking compatibility import: $file" >&2
      missing=1
    fi
  fi

  if grep -Eq 'CF(GetTypeID|BooleanGetTypeID)' "$file" &&
     ! grep -q '^import CoreFoundation$' "$file"; then
    echo "missing CoreFoundation compatibility import: $file" >&2
    missing=1
  fi
done < <(find Sources/AsyncRequestKit Tests/AsyncRequestKitTests -type f -name '*.swift' -print0)

exit "$missing"
