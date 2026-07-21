#!/usr/bin/env bash
set -euo pipefail

baseline_version="${1:?usage: Scripts/validate_api_compatibility.sh 0.4.0}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

[[ "$baseline_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
git rev-parse --verify --quiet "refs/tags/$baseline_version" >/dev/null
swift package diagnose-api-breaking-changes "$baseline_version"
