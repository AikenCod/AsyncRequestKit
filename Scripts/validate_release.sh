#!/usr/bin/env bash
set -euo pipefail

version="${1:?usage: Scripts/validate_release.sh 0.5.0}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

baseline_version="$(git tag --sort=-v:refname | head -n 1)"

[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
grep -q "spec.version      = \"$version\"" AsyncRequestKit.podspec
grep -q "from: \"$version\"" README.md
grep -q "from: \"$version\"" README.zh-CN.md
grep -q "## \[$version\]" CHANGELOG.md
Scripts/validate_repository_metadata.sh
Scripts/test_spm_consumer.sh
Scripts/validate_api_compatibility.sh "$baseline_version"
swift test
git diff --check
