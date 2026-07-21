# Open-Source Evidence Ledger

This ledger separates public facts from local work that has not been published.
All changing metrics must be refreshed immediately before an application is
reviewed or submitted.

| Claim | Value | Observation date | Source URL | Verification method |
| --- | --- | --- | --- | --- |
| Repository | Public, active repository owned by `AikenCod` | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit | GitHub repository API: `visibility=public`, `archived=false` |
| GitHub stars | 1 | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/stargazers | GitHub repository API `stargazers_count` |
| GitHub forks | 0 | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/forks | GitHub repository API `forks_count` |
| Release tags | 6 tags through annotated tag `0.5.0` | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/tags | GitHub tags API and remote tag verification |
| GitHub Releases | `AsyncRequestKit 0.5.0` published, not a draft or prerelease | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/releases/tag/0.5.0 | GitHub Releases API; published 2026-07-21T02:57:18Z |
| Public commit history | 24 commits on the default branch; most recent push 2026-07-21 | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/commits/main | GitHub commits and repository APIs |
| Issues | 0 public issues observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/issues | GitHub issues API, all states |
| Pull requests | 0 public pull requests observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/pulls | GitHub issues API, all states, filtered for pull requests |
| External contributors | Not observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/graphs/contributors | GitHub contributors API returned no entries; no independent contribution is claimed |
| Public license detection | MIT | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/blob/main/LICENSE | GitHub repository API `license=MIT` |
| Public CI | Successful macOS 15, Ubuntu 24.04, and CocoaPods jobs on release commit `2fd5029` | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/actions/runs/29797116986 | GitHub Actions run API; all three jobs concluded `success` |
| Tests | 28 Swift Testing tests pass on macOS and Ubuntu in public CI | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/actions/runs/29797116986 | Public `swift test` steps on both runner jobs |
| Clean SPM consumption | Temporary consumer builds successfully on macOS and Ubuntu in public CI | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/actions/runs/29797116986 | Public `Scripts/test_spm_consumer.sh` steps |
| CocoaPods metadata | Podspec lint passes publicly; Trunk publication unavailable because no registered local Trunk session exists | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/actions/runs/29797116986 | Green CocoaPods job and `pod trunk me`; no download count claimed |
| Swift Package Index | Official validation passed; automated PR `#14497` is open and awaiting SPI maintainer approval | 2026-07-21 | https://github.com/SwiftPackageIndex/PackageList/pull/14497 | Correctly labeled issue `#14496` triggered successful workflow run `29797733886`; unlabeled issue `#14495` was closed as superseded |
| Download/adoption metrics | Not observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit | No authoritative download source or downstream adopter recorded |
| Trust/readiness work | MIT metadata, CI, community files, changelog, DocC, guides, validation scripts, and the `0.5.0` trust release are public | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/releases/tag/0.5.0 | Public repository, green CI, tag, and GitHub Release |
| API compatibility | No public API breaking changes detected relative to `0.4.0` | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/blob/main/Scripts/validate_api_compatibility.sh | `swift package diagnose-api-breaking-changes 0.4.0` and committed release gate |
| Maintainer action | Diagnosed public CI failures, fixed Linux imports, strict-concurrency demo output, and a real queue-cancellation race before release | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/commits/main | Public commits and successful follow-up CI run |
| Maintainer role | `AikenCod` controls the repository and authenticated GitHub session; primary-maintainer wording requires the user's final confirmation | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit | GitHub authentication and repository ownership; final form value is user-confirmed |
| Program criteria | OpenAI considers usage, ecosystem importance, active maintenance, and maintainer responsibilities; selection is discretionary | 2026-07-21 | https://openai.com/form/codex-for-oss/ | Live official program page and linked terms |

## Readiness interpretation

The current public project now has an MIT license, green cross-platform CI,
six tags, a GitHub Release, DocC sources, production guides, and auditable
release checks. Adoption evidence remains minimal: one star, no forks, no
external contributors, no issue/PR history, and no authoritative downloads.
The trust release proves technical maintenance, not meaningful usage or
sustained activity; the application must keep those claims separate.
