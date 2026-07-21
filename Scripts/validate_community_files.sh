#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

for path in \
  SECURITY.md SUPPORT.md CONTRIBUTING.md CODE_OF_CONDUCT.md ROADMAP.md \
  .github/ISSUE_TEMPLATE/bug.yml \
  .github/ISSUE_TEMPLATE/feature.yml \
  .github/ISSUE_TEMPLATE/question.yml \
  .github/ISSUE_TEMPLATE/config.yml \
  .github/pull_request_template.md; do
  test -s "$path"
done

grep -q 'swift test' CONTRIBUTING.md
grep -q 'GitHub Security Advisories' SECURITY.md
grep -q '0.5.0' ROADMAP.md
grep -q '1.0.0' ROADMAP.md
