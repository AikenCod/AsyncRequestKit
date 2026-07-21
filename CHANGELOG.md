# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2026-07-21

### Added

- MIT license metadata and repository validation scripts, including a public API compatibility gate.
- GitHub Actions checks for Swift 6 on macOS and Linux, clean SwiftPM consumption, and CocoaPods metadata.
- Contributor, security, support, conduct, roadmap, issue, and pull-request policies.
- DocC catalog, Swift Package Index documentation configuration, release history, and production integration guides.
- Evidence-ledger and release gates for auditable maintenance and publication.

### Changed

- Added conditional `FoundationNetworking` imports for Linux compatibility.
- Replaced private podspec identity metadata with the public maintainer identity.

### Fixed

- Made running-job cancellation terminal even when an operation ignores task cancellation.
- Made the command-line demo compile under Linux strict-concurrency checks.

## [0.4.0] - 2026-05-26

### Added

- Multipart form-data uploads for text, in-memory data, and local files.
- Upload helpers that return decoded values or full response metadata.

## [0.3.2] - 2026-05-19

### Added

- CocoaPods distribution with an `AsyncRequestKit.podspec`.

## [0.3.1] - 2026-05-19

### Added

- Convenience request APIs for encoded bodies, dictionary parameters, empty responses, and response metadata.
- Separate English and Simplified Chinese documentation.

### Changed

- Raw requests now apply the same default headers as convenience requests.

## [0.3.0] - 2026-05-18

### Added

- Shared `AK` client facade and configurable `HTTPClient`.
- HTTP interceptors and coordinated token refresh support.
- Retry, timeout, cache, queue, and limited-concurrency utilities.

## [0.2.0] - 2026-05-18

### Added

- Initial public Swift Package release with cancellation-aware concurrency primitives.
- Bilingual README documentation and runnable examples.

[Unreleased]: https://github.com/AikenCod/AsyncRequestKit/compare/0.5.0...HEAD
[0.5.0]: https://github.com/AikenCod/AsyncRequestKit/compare/0.4.0...0.5.0
[0.4.0]: https://github.com/AikenCod/AsyncRequestKit/compare/0.3.2...0.4.0
[0.3.2]: https://github.com/AikenCod/AsyncRequestKit/compare/0.3.1...0.3.2
[0.3.1]: https://github.com/AikenCod/AsyncRequestKit/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/AikenCod/AsyncRequestKit/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/AikenCod/AsyncRequestKit/releases/tag/0.2.0
