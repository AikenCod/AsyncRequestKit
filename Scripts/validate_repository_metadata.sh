#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

test -f LICENSE
grep -q '^MIT License$' LICENSE
grep -q ':type => "MIT"' AsyncRequestKit.podspec
grep -q ':file => "LICENSE"' AsyncRequestKit.podspec
! grep -Eq 'Proprietary|Alex@qt\.com' AsyncRequestKit.podspec
grep -q 'MIT' README.md
grep -q 'MIT' README.zh-CN.md
swift package dump-package >/dev/null
pod lib lint AsyncRequestKit.podspec --quick --allow-warnings --skip-tests
