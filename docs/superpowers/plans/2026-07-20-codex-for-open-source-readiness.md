# Codex for Open Source Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn `AikenCod/AsyncRequestKit` into a verifiably maintained and adopted open-source Swift package, assemble an evidence-backed Codex for Open Source application, and submit it only after explicit user approval.

**Architecture:** Work proceeds through five evidence gates: open-source metadata, reproducible technical trust, ecosystem distribution, genuine community maintenance, and claim-by-claim application verification. Repository facts live in a version-controlled evidence ledger; external publication, outreach, and form submission remain explicit approval boundaries.

**Tech Stack:** Swift 6, Swift Package Manager, Swift Testing, CocoaPods 1.16, GitHub Actions, DocC, Swift Package Index, Markdown, Bash.

## Global Constraints

- Preserve Swift tools version `6.0` and minimum platforms macOS 13, iOS 16, tvOS 16, and watchOS 9 unless verified evidence requires narrowing support.
- Add no runtime package dependencies.
- Preserve source compatibility throughout the `0.x` campaign unless a breaking change is explicitly documented and approved.
- Never buy, exchange, automate, or fabricate stars, followers, downloads, issues, pull requests, testimonials, or activity.
- Never publish employer information, credentials, private analytics, or customer code.
- Do not push commits, publish packages or posts, contact people, create public issues, or submit forms without the corresponding user authorization.
- Treat OpenAI selection and the resulting ChatGPT Pro entitlement as external outcomes that must be verified; application submission alone does not complete the goal.

---

### Task 1: Establish Authentic Open-Source Metadata

**Files:**
- Create: `LICENSE`
- Create: `Scripts/validate_repository_metadata.sh`
- Modify: `AsyncRequestKit.podspec`
- Modify: `README.md`
- Modify: `README.zh-CN.md`

**Interfaces:**
- Consumes: existing SwiftPM manifest and CocoaPods podspec.
- Produces: an MIT-licensed repository and `Scripts/validate_repository_metadata.sh`, used by CI and release validation.

- [ ] **Step 1: Write the metadata validator first**

```bash
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
```

- [ ] **Step 2: Run the validator and verify the current metadata fails**

Run: `chmod +x Scripts/validate_repository_metadata.sh && Scripts/validate_repository_metadata.sh`

Expected: FAIL because `LICENSE` does not exist and the podspec declares `Proprietary`.

- [ ] **Step 3: Add the MIT license**

```text
MIT License

Copyright (c) 2026 AikenCod

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 4: Replace misleading podspec identity and license fields**

```ruby
spec.license      = { :type => "MIT", :file => "LICENSE" }
spec.author       = "AikenCod"
```

- [ ] **Step 5: Add an MIT license section to both READMEs**

```markdown
## License

AsyncRequestKit is available under the MIT License. See [LICENSE](LICENSE).
```

Use the equivalent Chinese text in `README.zh-CN.md` while preserving the same link.

- [ ] **Step 6: Run metadata, package, podspec, and test verification**

Run: `Scripts/validate_repository_metadata.sh && swift test`

Expected: podspec validation passes and all 28 Swift tests pass.

- [ ] **Step 7: Commit the metadata correction**

```bash
git add LICENSE Scripts/validate_repository_metadata.sh AsyncRequestKit.podspec README.md README.zh-CN.md
git commit -m "docs: establish MIT open source metadata"
```

---

### Task 2: Prove macOS and Linux Builds in Continuous Integration

**Files:**
- Create: `.github/workflows/ci.yml`
- Modify: `Sources/AsyncRequestKit/HTTP/HTTPClient+Convenience.swift`
- Modify: `Sources/AsyncRequestKit/HTTP/HTTPClient+Execution.swift`
- Modify: `Sources/AsyncRequestKit/HTTP/HTTPClient+RequestSupport.swift`
- Modify: `Sources/AsyncRequestKit/HTTP/HTTPClient+Upload.swift`
- Modify: `Sources/AsyncRequestKit/HTTP/HTTPClient.swift`
- Modify: `Sources/AsyncRequestKit/HTTP/HTTPInterceptor.swift`
- Modify: `Sources/AsyncRequestKit/HTTP/HTTPResponse.swift`
- Modify: `Sources/AsyncRequestKit/HTTP/ParameterEncoding.swift`
- Modify: `Tests/AsyncRequestKitTests/AsyncRequestKitTests.swift`

**Interfaces:**
- Consumes: public API and current 28-test suite.
- Produces: Linux-compilable networking types and two authoritative CI jobs.

- [ ] **Step 1: Add the CI workflow before portability changes**

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

permissions:
  contents: read

jobs:
  swift-test:
    name: Swift ${{ matrix.swift }} on ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        include:
          - os: macos-15
            swift: "6.0"
          - os: ubuntu-24.04
            swift: "6.0"
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: swift-actions/setup-swift@v2
        with:
          swift-version: ${{ matrix.swift }}
      - run: swift --version
      - run: swift package dump-package
      - run: swift test

  pod-lint:
    name: CocoaPods lint
    runs-on: macos-15
    steps:
      - uses: actions/checkout@v4
      - run: pod lib lint AsyncRequestKit.podspec --quick --allow-warnings --skip-tests
```

- [ ] **Step 2: Record the expected Linux failure before fixing imports**

Push only after the user approves the first publication checkpoint. Inspect the `ubuntu-24.04` job.

Expected before the fix: networking symbols such as `URLRequest` or `HTTPURLResponse` are unavailable without `FoundationNetworking`.

- [ ] **Step 3: Add conditional networking imports to every affected source file**

Immediately after `import Foundation`, add:

```swift
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
```

Apply the same import to `Tests/AsyncRequestKitTests/AsyncRequestKitTests.swift` so Linux tests can construct URL loading types.

- [ ] **Step 4: Run the local macOS regression suite**

Run: `swift test`

Expected: all 28 tests pass.

- [ ] **Step 5: Commit Linux portability and CI**

```bash
git add .github/workflows/ci.yml Sources/AsyncRequestKit/HTTP Tests/AsyncRequestKitTests/AsyncRequestKitTests.swift
git commit -m "ci: verify Swift package across macOS and Linux"
```

- [ ] **Step 6: Verify both CI jobs after an approved push**

Run: `gh run list --workflow CI --limit 1`

Then run: `gh run watch "$(gh run list --workflow CI --limit 1 --json databaseId --jq '.[0].databaseId')" --exit-status`

Expected: macOS, Ubuntu, and CocoaPods jobs all succeed. Do not document Linux support until this evidence exists.

---

### Task 3: Add Clean-Consumer and Release Invariant Checks

**Files:**
- Create: `Scripts/test_spm_consumer.sh`
- Create: `Scripts/validate_release.sh`
- Modify: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: local repository path, semantic version argument, README installation snippets, and podspec version.
- Produces: clean SwiftPM consumption proof and a release consistency gate.

- [ ] **Step 1: Write a clean-consumer script**

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_root="$(mktemp -d)"
trap 'rm -rf "$fixture_root"' EXIT

cd "$fixture_root"
swift package init --type executable --name AsyncRequestKitConsumer >/dev/null

cat > Package.swift <<EOF
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AsyncRequestKitConsumer",
    platforms: [.macOS(.v13)],
    dependencies: [.package(name: "AsyncRequestKit", path: "$repo_root")],
    targets: [
        .executableTarget(
            name: "AsyncRequestKitConsumer",
            dependencies: [.product(name: "AsyncRequestKit", package: "AsyncRequestKit")]
        )
    ]
)
EOF

cat > Sources/main.swift <<'EOF'
import AsyncRequestKit
import Foundation

let client = HTTPClient(configuration: HTTPClientConfiguration())
print(String(describing: client))
EOF

swift build
```

- [ ] **Step 2: Run the consumer script**

Run: `chmod +x Scripts/test_spm_consumer.sh && Scripts/test_spm_consumer.sh`

Expected: a clean temporary executable resolves the local package and builds.

- [ ] **Step 3: Write the release invariant script**

```bash
#!/usr/bin/env bash
set -euo pipefail

version="${1:?usage: Scripts/validate_release.sh 0.5.0}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
grep -q "spec.version      = \"$version\"" AsyncRequestKit.podspec
grep -q "from: \"$version\"" README.md
grep -q "from: \"$version\"" README.zh-CN.md
grep -q "## \[$version\]" CHANGELOG.md
Scripts/validate_repository_metadata.sh
Scripts/test_spm_consumer.sh
swift test
git diff --check
```

- [ ] **Step 4: Run the release script and verify the missing changelog fails**

Run: `chmod +x Scripts/validate_release.sh && Scripts/validate_release.sh 0.4.0`

Expected: FAIL because `CHANGELOG.md` does not yet exist.

- [ ] **Step 5: Add both scripts to CI**

Add these steps to the macOS matrix entry or a dedicated `integration` job:

```yaml
      - run: Scripts/validate_repository_metadata.sh
      - run: Scripts/test_spm_consumer.sh
```

Do not run `validate_release.sh` on every branch because its version argument changes per release.

- [ ] **Step 6: Commit the integration gates**

```bash
git add Scripts/test_spm_consumer.sh Scripts/validate_release.sh .github/workflows/ci.yml
git commit -m "test: validate clean package consumption"
```

---

### Task 4: Publish Maintainer, Security, and Contribution Policies

**Files:**
- Create: `SECURITY.md`
- Create: `SUPPORT.md`
- Create: `CONTRIBUTING.md`
- Create: `CODE_OF_CONDUCT.md`
- Create: `ROADMAP.md`
- Create: `.github/ISSUE_TEMPLATE/bug.yml`
- Create: `.github/ISSUE_TEMPLATE/feature.yml`
- Create: `.github/ISSUE_TEMPLATE/config.yml`
- Create: `.github/pull_request_template.md`
- Create: `Scripts/validate_community_files.sh`

**Interfaces:**
- Consumes: supported platforms and current `0.4.0` behavior.
- Produces: public triage routes, review expectations, security reporting policy, and a non-artificial roadmap.

- [ ] **Step 1: Add a structural validator that fails before policy files exist**

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

for path in \
  SECURITY.md SUPPORT.md CONTRIBUTING.md CODE_OF_CONDUCT.md ROADMAP.md \
  .github/ISSUE_TEMPLATE/bug.yml \
  .github/ISSUE_TEMPLATE/feature.yml \
  .github/ISSUE_TEMPLATE/config.yml \
  .github/pull_request_template.md; do
  test -s "$path"
done

grep -q 'swift test' CONTRIBUTING.md
grep -q 'GitHub Security Advisories' SECURITY.md
grep -q '0.5.0' ROADMAP.md
grep -q '1.0.0' ROADMAP.md
```

- [ ] **Step 2: Run the validator and confirm it fails**

Run: `chmod +x Scripts/validate_community_files.sh && Scripts/validate_community_files.sh`

Expected: FAIL on the first missing policy file.

- [ ] **Step 3: Write focused policies**

`SECURITY.md` must direct private vulnerability reports to GitHub Security Advisories and list supported versions as `0.4.x` only. `SUPPORT.md` must route reproducible bugs to Issues and general integration questions to Discussions if Discussions is enabled. `CONTRIBUTING.md` must require a focused issue or PR, `swift test`, source-compatible behavior, and no generated activity. Use Contributor Covenant 2.1 verbatim in `CODE_OF_CONDUCT.md` with GitHub reporting as the enforcement contact.

- [ ] **Step 4: Write the roadmap**

Use three evidence-driven sections:

```markdown
## 0.5.0 — Portability and trust
- Linux CI and FoundationNetworking compatibility
- MIT metadata and maintainer policies
- clean-consumer verification

## 0.6.0 — Documentation and distribution
- DocC catalog and Swift Package Index listing
- authentication, retry, and upload integration guides
- verified CocoaPods installation

## 1.0.0 — Stable API
- public API review and compatibility policy
- migration guide from 0.6.x
- adopter feedback incorporated with linked issues
```

- [ ] **Step 5: Add GitHub issue forms and PR checklist**

Bug reports must request version, platform, Swift version, minimal reproduction, expected result, and actual result. Feature requests must request the user problem, proposed API, alternatives, and source-compatibility impact. The PR template must require linked issue, tests, docs, changelog impact, and confirmation that no secrets or proprietary code are included.

- [ ] **Step 6: Run policy verification**

Run: `Scripts/validate_community_files.sh && git diff --check`

Expected: PASS.

- [ ] **Step 7: Commit community infrastructure**

```bash
git add SECURITY.md SUPPORT.md CONTRIBUTING.md CODE_OF_CONDUCT.md ROADMAP.md .github Scripts/validate_community_files.sh
git commit -m "docs: define maintainer and contribution policies"
```

---

### Task 5: Add Release History and DocC Discovery

**Files:**
- Create: `CHANGELOG.md`
- Create: `.spi.yml`
- Create: `Sources/AsyncRequestKit/AsyncRequestKit.docc/AsyncRequestKit.md`
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: public declarations under `Sources/AsyncRequestKit/`

**Interfaces:**
- Consumes: git tags `0.2.0` through `0.4.0`, existing public APIs, and Swift Package Index manifest version 1.
- Produces: auditable release history and hosted-documentation configuration for target `AsyncRequestKit`.

- [ ] **Step 1: Reconstruct a factual changelog from tagged commits**

Create Keep-a-Changelog-style sections for `0.4.0`, `0.3.2`, `0.3.1`, `0.3.0`, and `0.2.0`. Each heading must use `## [0.4.0] - 2026-05-26` syntax and link to the corresponding GitHub compare or tag URL.

- [ ] **Step 2: Verify the release invariant now passes for 0.4.0**

Run: `Scripts/validate_release.sh 0.4.0`

Expected: metadata, clean consumer, package tests, and changelog checks all pass.

- [ ] **Step 3: Add Swift Package Index documentation configuration**

```yaml
version: 1
builder:
  configs:
    - documentation_targets: [AsyncRequestKit]
```

Validate the exact file at `https://swiftpackageindex.com/validate-spi-manifest` before any approved public submission.

- [ ] **Step 4: Add the DocC landing article**

```markdown
# ``AsyncRequestKit``

A Swift Concurrency networking toolkit for explicit retry, timeout,
request coordination, controlled parallelism, and token refresh.

## Overview

Use ``HTTPClient`` when an application needs an isolated client and ``AK``
when a shared facade is appropriate. Compose ``RetryPolicy`` and
``TokenRefreshCoordinator`` instead of hiding retry or authentication work.

## Topics

### Requests
- ``HTTPClient``
- ``AK``
- ``HTTPResponse``

### Reliability
- ``RetryPolicy``
- ``TokenRefreshCoordinator``

### Coordination
- ``AsyncQueue``
- ``AsyncCache``
```

- [ ] **Step 5: Add concise `///` documentation to public declarations**

Document observable behavior, concurrency guarantees, cancellation, errors, and default values. Do not restate symbol names. Work file-by-file and run `swift test` after each HTTP, queue, cache, retry, and timeout group.

- [ ] **Step 6: Build DocC locally with Xcode**

Run: `xcodebuild docbuild -scheme AsyncRequestKit -destination 'generic/platform=macOS' -derivedDataPath .build/docc`

Expected: `** BUILD SUCCEEDED **` with no unresolved DocC links.

- [ ] **Step 7: Add README links to changelog, security, contributing, roadmap, and DocC source**

Keep English and Chinese README navigation structurally equivalent. Do not add CI or Swift Package Index badges until the corresponding public pages succeed.

- [ ] **Step 8: Commit release history and documentation discovery**

```bash
git add CHANGELOG.md .spi.yml Sources/AsyncRequestKit README.md README.zh-CN.md
git commit -m "docs: add release history and DocC catalog"
```

---

### Task 6: Add Real Integration Guides

**Files:**
- Create: `docs/guides/authenticated-client.md`
- Create: `docs/guides/multipart-upload.md`
- Create: `docs/guides/adoption-checklist.md`
- Modify: `README.md`
- Modify: `README.zh-CN.md`

**Interfaces:**
- Consumes: tested `HTTPInterceptor`, `TokenRefreshCoordinator`, multipart upload, and response metadata APIs.
- Produces: discoverable evaluation paths for real adopters and a reproducible adoption checklist.

- [ ] **Step 1: Write the authenticated-client guide**

Include a complete actor-backed token store, one coalesced refresh path, retry limit behavior, 401 handling, cancellation expectations, and a testable transport stub. Every API name must match a compiled test or source declaration.

- [ ] **Step 2: Write the multipart guide**

Cover text fields, binary fields, MIME type, filename, memory implications for small uploads, response decoding, timeout, and server-side size errors. Do not claim streaming upload support unless it is implemented and tested.

- [ ] **Step 3: Write the adoption checklist**

The checklist must require readers to verify supported platform, Swift 6 mode, retry idempotency, authentication refresh behavior, cancellation, upload size, and migration risk before adoption.

- [ ] **Step 4: Verify every guide symbol against the source**

Run: `rg -o '\`\`?[A-Z][A-Za-z0-9]+' docs/guides README.md | sort -u`

For each package symbol reported, confirm it appears in the declaration inventory produced by `rg -n 'public (actor|class|enum|func|struct|protocol|typealias|var|let)' Sources/AsyncRequestKit`.

- [ ] **Step 5: Run full technical verification**

Run: `swift test && Scripts/test_spm_consumer.sh && xcodebuild docbuild -scheme AsyncRequestKit -destination 'generic/platform=macOS' -derivedDataPath .build/docc`

Expected: 28 or more tests pass, the clean consumer builds, and DocC succeeds.

- [ ] **Step 6: Commit adoption guides**

```bash
git add docs/guides README.md README.zh-CN.md
git commit -m "docs: add production integration guides"
```

---

### Task 7: Create the Evidence Ledger and Application Draft Validator

**Files:**
- Create: `docs/oss/EVIDENCE.md`
- Create: `docs/oss/application/qualification.txt`
- Create: `docs/oss/application/api-credit-use.txt`
- Create: `docs/oss/APPLICATION_REVIEW.md`
- Create: `Scripts/validate_application_materials.sh`

**Interfaces:**
- Consumes: authoritative public URLs, dated metrics, maintainer actions, user-supplied ChatGPT email, and OpenAI Organization ID.
- Produces: claim-to-source mapping and two validated maximum-500-character application responses.

- [ ] **Step 1: Write the application-material validator**

```bash
#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

for path in \
  docs/oss/EVIDENCE.md \
  docs/oss/application/qualification.txt \
  docs/oss/application/api-credit-use.txt \
  docs/oss/APPLICATION_REVIEW.md; do
  test -s "$path"
done

for path in docs/oss/application/*.txt; do
  count="$(python3 -c 'import pathlib,sys; print(len(pathlib.Path(sys.argv[1]).read_text().strip()))' "$path")"
  test "$count" -le 500
done

grep -q 'https://github.com/AikenCod/AsyncRequestKit' docs/oss/EVIDENCE.md
grep -q 'Observation date' docs/oss/EVIDENCE.md
! grep -Eqi 'guaranteed|widely adopted|industry-leading' docs/oss/application/*.txt
```

- [ ] **Step 2: Run the validator and verify it fails before artifacts exist**

Run: `chmod +x Scripts/validate_application_materials.sh && Scripts/validate_application_materials.sh`

Expected: FAIL on the first missing evidence artifact.

- [ ] **Step 3: Create the evidence ledger with current facts only**

Use a table with columns `Claim`, `Value`, `Observation date`, `Source URL`, and `Verification method`. Seed it with repository URL, release tags, CI state, license, tests, stars, forks, external contributors, package-index state, downloads, public guides, issues/PRs, and maintainer actions. Use `Not observed` for missing evidence rather than leaving cells blank.

- [ ] **Step 4: Create an honest initial qualification response**

```text
AsyncRequestKit is an MIT-licensed Swift 6 concurrency networking toolkit that I created and maintain. It provides explicit retry, timeout, request coordination, controlled parallelism, token refresh, and multipart support, with tests, bilingual documentation, semantic releases, and reproducible SPM/CocoaPods installation. I handle API design, issues, compatibility, releases, and security response.
```

Refresh this text with verified adoption evidence before submission; do not add unverified numbers.

- [ ] **Step 5: Create the API-credit use response**

```text
I will use API credits to assist issue triage, turn confirmed bug reports into reproducible tests, detect public API/documentation drift, review pull requests, and draft changelog entries for AsyncRequestKit. Human approval will remain required for labels, comments, merges, releases, and security decisions, and automation outputs will be auditable in the public repository.
```

- [ ] **Step 6: Create the application review checklist**

Require the live form URL, ChatGPT email, GitHub username, repository URL, primary-maintainer role, Organization ID, both character counts, evidence links for every claim, current terms, region eligibility, final user approval, submission timestamp, response email, and entitlement verification. Mark unavailable personal values as `User-supplied at final review`.

- [ ] **Step 7: Run the validator**

Run: `Scripts/validate_application_materials.sh`

Expected: PASS, with both response files at or below 500 characters.

- [ ] **Step 8: Commit evidence infrastructure**

```bash
git add docs/oss Scripts/validate_application_materials.sh
git commit -m "docs: add OSS evidence and application ledger"
```

---

### Task 8: Prepare and Publish the 0.5.0 Trust Release

**Files:**
- Create: `docs/releases/0.5.0.md`
- Modify: `AsyncRequestKit.podspec`
- Modify: `README.md`
- Modify: `README.zh-CN.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/oss/EVIDENCE.md`

**Interfaces:**
- Consumes: completed Tasks 1–7 and green CI.
- Produces: semantic tag `0.5.0`, GitHub release, and verifiable distribution candidates.

- [ ] **Step 1: Update version references to 0.5.0**

Set the podspec version and both README SPM examples to `0.5.0`. Add a dated changelog section containing only merged changes.

- [ ] **Step 2: Run the release gate**

Run: `Scripts/validate_release.sh 0.5.0`

Expected: all metadata, consumer, podspec, test, changelog, and diff checks pass.

- [ ] **Step 3: Commit release preparation**

```bash
git add AsyncRequestKit.podspec README.md README.zh-CN.md CHANGELOG.md
git commit -m "release: prepare AsyncRequestKit 0.5.0"
```

- [ ] **Step 4: Request approval for the first public push and release**

Present the exact commits, diff summary, test evidence, intended tag, GitHub release title/body, Swift Package Index submission, and CocoaPods command. Do not proceed until the user explicitly authorizes these public actions.

- [ ] **Step 5: Push commits and verify CI after approval**

Run: `git push origin main`

Then run: `gh run list --workflow CI --limit 1` and `gh run watch "$(gh run list --workflow CI --limit 1 --json databaseId --jq '.[0].databaseId')" --exit-status`.

Expected: all jobs succeed on the pushed commit.

- [ ] **Step 6: Create and push the signed release tag after green CI**

```bash
git tag -s 0.5.0 -m "AsyncRequestKit 0.5.0"
git push origin 0.5.0
```

If signing is not configured, stop and ask whether to configure signing or use an annotated tag; do not silently downgrade provenance.

- [ ] **Step 7: Create the GitHub release after approval**

Write the reviewed release summary to `docs/releases/0.5.0.md`, then run: `gh release create 0.5.0 --verify-tag --title "AsyncRequestKit 0.5.0" --notes-file docs/releases/0.5.0.md`

Expected: a public release URL whose notes match the reviewed changelog.

- [ ] **Step 8: Submit to Swift Package Index after approval**

Submit `https://github.com/AikenCod/AsyncRequestKit.git` at `https://swiftpackageindex.com/add-a-package`. Verify the public package page, platform matrix, license, release, and DocC link before recording the URL.

- [ ] **Step 9: Publish the pod only if CocoaPods ownership is verified and approved**

Run: `pod trunk me`, then `pod trunk push AsyncRequestKit.podspec`.

Expected: the trunk owner matches the user-authorized identity and the published `0.5.0` spec resolves. If ownership is missing, record CocoaPods as unavailable and do not imply publication.

- [ ] **Step 10: Refresh the evidence ledger and commit only factual results**

Record public URLs, timestamps, CI run, SPI compatibility results, and CocoaPods status. Use `Not published` or `Pending index build` when applicable.

---

### Task 9: Run an Eight-Week Genuine Maintenance Campaign

**Files:**
- Modify: `docs/oss/EVIDENCE.md`
- Modify: `ROADMAP.md`
- Modify: `CHANGELOG.md`
- Modify: source, tests, and guides only for confirmed project needs.

**Interfaces:**
- Consumes: real user reports, real adopter feedback, CI failures, and roadmap work.
- Produces: a sustained, auditable maintainer timeline rather than artificial commit volume.

- [ ] **Step 1: Review incoming activity once per week**

Inspect GitHub Issues, pull requests, Discussions, CI, Swift Package Index builds, and published package status. Record the observation date even when no external activity exists.

- [ ] **Step 2: Triage each legitimate report**

Reproduce bugs before changing code; label the issue by type and status; state what evidence is missing; link the test and release that resolves it. Request user approval before posting public replies through browser tooling.

- [ ] **Step 3: Review each legitimate external pull request**

Check scope, tests, docs, compatibility, licensing, and security. Never merge solely to create contributor evidence.

- [ ] **Step 4: Deliver roadmap work only when it creates user value**

Use test-driven implementation and semantic commits. Skip a week when there is no justified change; an honest quiet week is better evidence than fabricated activity.

- [ ] **Step 5: Publish releases only for coherent changes**

Run the release gate, request publication approval, wait for green CI, then create a reviewed semantic release. Record issues and PRs linked by the release.

- [ ] **Step 6: Collect independent adoption evidence**

Accept public downstream repository links, package-index metrics, CocoaPods metrics, or explicitly authorized adopter statements. Record the source and observation date. Do not cold-message strangers or request reciprocal stars.

- [ ] **Step 7: Audit readiness at weeks 4 and 8**

Compare the ledger against OpenAI's live criteria: usage/adoption or ecosystem importance, active maintenance, review/triage/releases, and concrete API-credit use. If evidence is still weak, continue maintenance rather than inflate the application.

---

### Task 10: Finalize, Review, and Submit the Application

**Files:**
- Modify: `docs/oss/EVIDENCE.md`
- Modify: `docs/oss/application/qualification.txt`
- Modify: `docs/oss/application/api-credit-use.txt`
- Modify: `docs/oss/APPLICATION_REVIEW.md`

**Interfaces:**
- Consumes: live OpenAI form and terms, refreshed evidence ledger, user-supplied ChatGPT email and Organization ID.
- Produces: one reviewed application and externally verifiable submission/entitlement state.

- [ ] **Step 1: Re-fetch the official program page and terms**

Use `https://openai.com/form/codex-for-oss/` and its linked current terms. Record the access date and any changed eligibility, fields, benefits, or restrictions.

- [ ] **Step 2: Refresh every metric from its authoritative source**

Update stars, forks, releases, external contributors, issues, PRs, package listings, downloads, documentation, CI, and maintainer actions. Do not use screenshots or cached search snippets when a live public page is available.

- [ ] **Step 3: Rewrite the qualification response from verified evidence**

Keep it at or below 500 characters. Every number and adoption claim must map to one evidence-ledger row. Retain the primary-maintainer role and ecosystem problem even when metrics remain modest.

- [ ] **Step 4: Revalidate the API-credit response**

Keep it specific to AsyncRequestKit issue triage, reproducible tests, documentation drift, PR review, and changelogs, with human approval for external actions.

- [ ] **Step 5: Obtain the two required personal values from the user**

Request the email associated with the target ChatGPT account and the OpenAI Organization ID. Do not infer, scrape, or expose either value.

- [ ] **Step 6: Run the application validator and claim audit**

Run: `Scripts/validate_application_materials.sh`

Then inspect each sentence in both response files against `docs/oss/EVIDENCE.md`.

Expected: both files are within 500 characters and every material claim has current evidence.

- [ ] **Step 7: Fill the form without submitting**

Populate the reviewed fields in the official OpenAI form. Stop at the final submit action and present the exact transmitted values, current terms, and evidence summary to the user.

- [ ] **Step 8: Request explicit final submission approval**

The confirmation must name the destination (`OpenAI Codex for Open Source`), the GitHub identity, repository, ChatGPT email, Organization ID, and the fact that submission transmits these values externally.

- [ ] **Step 9: Submit and capture authoritative confirmation**

After approval, submit once. Record the confirmation message, timestamp, and any application reference without exposing private identifiers in public repository files.

- [ ] **Step 10: Monitor the application result**

Only official OpenAI email, account entitlement, or program communication counts as a result. Respond to legitimate requests for clarification with user approval.

- [ ] **Step 11: Verify program success before completing the goal**

Confirm the target ChatGPT account shows six months of ChatGPT Pro or equivalent official entitlement described by the accepted offer. If the application is pending or rejected, keep the goal incomplete and continue with truthful next steps.

---

## Plan Self-Review Checklist

- Each design workstream maps to at least one task: credibility (1–6), distribution (8), community maintenance (4 and 9), evidence (7), application (10).
- External actions have explicit approval gates.
- Technical claims are proven by tests, CI, clean-consumer builds, pod lint, DocC, or public index pages.
- Adoption and maintainer claims require public, dated evidence and cannot be inferred from passing tests.
- Application submission and program acceptance are distinct states.
