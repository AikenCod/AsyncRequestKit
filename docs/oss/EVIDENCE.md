# Open-Source Evidence Ledger

This ledger separates public facts from local work that has not been published.
All changing metrics must be refreshed immediately before an application is
reviewed or submitted.

| Claim | Value | Observation date | Source URL | Verification method |
| --- | --- | --- | --- | --- |
| Repository | Public, active repository owned by `AikenCod` | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit | GitHub repository API: `visibility=public`, `archived=false` |
| GitHub stars | 1 | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/stargazers | GitHub repository API `stargazers_count` |
| GitHub forks | 0 | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/forks | GitHub repository API `forks_count` |
| Release tags | 5 tags: `0.2.0`, `0.3.0`, `0.3.1`, `0.3.2`, `0.4.0` | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/tags | GitHub tags API |
| GitHub Releases | 0 published GitHub Release objects | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/releases | GitHub releases API returned an empty list |
| Public commit history | 10 commits on the default branch; most recent push 2026-05-26 | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/commits/main | GitHub commits and repository APIs |
| Issues | 0 public issues observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/issues | GitHub issues API, all states |
| Pull requests | 0 public pull requests observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/pulls | GitHub issues API, all states, filtered for pull requests |
| External contributors | Not observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/graphs/contributors | GitHub contributors API returned no entries; no independent contribution is claimed |
| Public license detection | No license detected on the public default branch | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit | GitHub repository API `license=null` |
| Public CI | No GitHub Actions workflow or run observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/actions | GitHub workflows and runs APIs returned empty lists |
| Tests | 28 Swift Testing tests pass locally on macOS | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/tree/main/Tests | `swift test`; this result is not yet public CI evidence |
| Clean SPM consumption | Local temporary consumer builds successfully | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/blob/main/Package.swift | `Scripts/test_spm_consumer.sh`; script is pending publication |
| CocoaPods metadata | Podspec exists publicly; package publication/downloads not observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit/blob/main/AsyncRequestKit.podspec | GitHub file and local `pod lib lint`; no download count claimed |
| Swift Package Index | Not observed | 2026-07-21 | https://swiftpackageindex.com/search?query=AsyncRequestKit | No verified public package page recorded |
| Download/adoption metrics | Not observed | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit | No authoritative download source or downstream adopter recorded |
| Trust/readiness work | MIT metadata, CI, community files, changelog, DocC, guides, and validation scripts exist only in local commits after `origin/main` | 2026-07-21 | Not public | `git log origin/main..main`; must not be described as public until pushed and verified |
| Maintainer role | `AikenCod` controls the repository and authenticated GitHub session; primary-maintainer wording requires the user's final confirmation | 2026-07-21 | https://github.com/AikenCod/AsyncRequestKit | GitHub authentication and repository ownership; final form value is user-confirmed |
| Program criteria | OpenAI considers usage, ecosystem importance, active maintenance, and maintainer responsibilities; selection is discretionary | 2026-07-21 | https://openai.com/form/codex-for-oss/ | Live official program page and linked terms |

## Readiness interpretation

The current public project has real code and five tags, but it has minimal
adoption evidence and no public CI, detected license, issue/PR history, or
GitHub Releases. The local trust work improves verifiability but does not prove
meaningful usage or sustained maintenance until it is published and followed
by genuine activity. No application should describe the pending work as public.
