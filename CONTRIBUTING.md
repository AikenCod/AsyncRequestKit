# Contributing to AsyncRequestKit

Thank you for considering a contribution. The project values focused changes
that solve a demonstrated user problem and preserve predictable concurrency
and networking behavior.

## Before You Start

1. Search existing issues and pull requests.
2. Open a focused issue for non-trivial behavior or API changes.
3. Keep proprietary code, credentials, customer data, and private endpoints out
   of reports, tests, examples, and commits.
4. Do not create artificial issues, commits, pull requests, or other activity.

Small documentation corrections may be submitted directly when their intent is
unambiguous.

## Development

AsyncRequestKit requires Swift 6. Clone the repository and run:

```bash
swift test
Scripts/test_spm_consumer.sh
Scripts/validate_repository_metadata.sh
Scripts/validate_linux_imports.sh
```

All checks must pass before a pull request is ready for review.

## Change Requirements

- Add a failing test before fixing a bug or adding behavior.
- Keep public API changes source-compatible during the `0.x` campaign unless a
  breaking change is explicitly discussed and documented.
- Document observable behavior, cancellation, errors, defaults, and platform
  constraints.
- Update the changelog when a user-visible change is ready for release.
- Keep commits scoped and explain why the change is needed.

## Pull Requests

Use the pull request template, link the relevant issue, and describe the test
evidence. A maintainer may request a smaller scope, additional tests, API
changes, or documentation before merging. Contributions are merged because
they improve the project, never merely to create activity metrics.

By contributing, you agree that your contribution is licensed under the MIT
License and that you will follow [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
