# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/AikenCod/AsyncRequestKit/compare/0.4.0...HEAD
[0.4.0]: https://github.com/AikenCod/AsyncRequestKit/compare/0.3.2...0.4.0
[0.3.2]: https://github.com/AikenCod/AsyncRequestKit/compare/0.3.1...0.3.2
[0.3.1]: https://github.com/AikenCod/AsyncRequestKit/compare/0.3.0...0.3.1
[0.3.0]: https://github.com/AikenCod/AsyncRequestKit/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/AikenCod/AsyncRequestKit/releases/tag/0.2.0
