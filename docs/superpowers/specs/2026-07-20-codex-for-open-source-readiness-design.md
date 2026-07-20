# Codex for Open Source Readiness Design

## Objective

Make `AikenCod/AsyncRequestKit` a credible, actively maintained open-source Swift package with verifiable adoption and community evidence, then prepare an accurate Codex for Open Source application for its primary maintainer.

The desired external outcome is selection for the program's six months of ChatGPT Pro. OpenAI makes the selection decision, so this project optimizes the quality and truthfulness of the evidence without claiming or guaranteeing approval.

## Official Selection Signals

The [Codex for Open Source application](https://openai.com/form/codex-for-oss/) says that OpenAI reviews:

- meaningful usage, broad adoption, or clear ecosystem importance;
- evidence of active maintenance;
- pull-request review, issue triage, release management, and other ongoing responsibilities of primary or core maintainers;
- a concrete proposed use for API credits in coding, review, automation, or release workflows.

No public minimum for stars, downloads, contributors, or project age is assumed. Application claims must be supported by live links or reproducible metrics at submission time.

## Current Baseline

As of 2026-07-20:

- `AsyncRequestKit` is an original public Swift package owned by `AikenCod`.
- The repository has 10 commits, five tags, one star, and no forks visible on GitHub.
- The latest published work is version `0.4.0`, dated 2026-05-26.
- Installation documentation covers Swift Package Manager and CocoaPods.
- The repository includes English and Chinese documentation, an example app, an executable demo, and an MIT license.
- `swift test` passes 28 tests locally on macOS.
- The maintainer profile shows seven public contributions in the preceding year and no followers.
- No verifiable package download count, downstream adopter list, external contributor history, or sustained issue-triage history is currently visible.

This baseline is sufficient to apply as a primary maintainer, but it is not yet strong evidence of meaningful adoption or ongoing community maintenance.

## Chosen Strategy

Use an 8–12 week project-first campaign centered on `AsyncRequestKit`. Treat `AsyncRequestKitSSE` as a companion integration, not a competing primary application project.

This approach is preferred over applying immediately because it directly improves the signals OpenAI says it evaluates. It is preferred over relying mainly on contributions to unrelated projects because the maintainer can control release quality, documentation, evidence collection, and response time in an owned project.

## Ethical and Operational Constraints

- Do not buy, exchange, or automate stars, followers, downloads, issues, pull requests, or testimonials.
- Do not split changes into artificial commits or create fake activity.
- Do not present one-off contributions to another repository as core-maintainer work.
- Do not expose employer code, private customer information, credentials, analytics identifiers, or unpublished product details.
- Do not publish a package, create public posts, contact people, push commits, or submit the OpenAI form without the appropriate user authorization at that action boundary.
- Preserve semantic versioning and source compatibility unless a documented major-version decision is approved.
- Record unfavorable or small metrics honestly; never omit context in a way that makes a claim misleading.

## Workstreams

### 1. Repository Credibility

The repository should make its purpose, stability, and maintenance practices understandable without reading the implementation.

Deliverables:

- a concise problem statement and positioning against direct alternatives;
- a documented support matrix for Swift, Apple platforms, and Linux where verified;
- continuous integration for supported platforms and Swift versions;
- test coverage for public HTTP, retry, timeout, upload, token-refresh, queue, cache, and concurrency behavior;
- API documentation generated from source comments;
- `SECURITY.md`, a maintenance policy, issue forms, and contribution guidance;
- an explicit roadmap from `0.4.x` to a stable `1.0.0` API;
- reproducible benchmarks only where they help users make a real adoption decision.

The implementation should favor small, reviewable improvements with tests. Activity is an output of real maintenance, not a target by itself.

### 2. Distribution and Discoverability

Users must be able to find, evaluate, install, and verify the package through normal Swift ecosystem channels.

Deliverables:

- validate Swift Package Manager installation from a clean consumer project;
- validate the podspec locally before any CocoaPods publication;
- prepare Swift Package Index metadata and documentation compatibility;
- use GitHub releases with changelogs and migration notes;
- add accurate repository topics and a small documentation site or DocC archive if it materially improves evaluation;
- publish one substantial English guide and one Chinese guide built around real integration scenarios;
- clearly connect `AsyncRequestKitSSE` as an optional companion package.

External publication and outreach are separate approval gates. Prepared material may be committed locally before those gates.

### 3. Community Maintenance

The project should invite and visibly respond to legitimate user participation.

Deliverables:

- scoped issues for the roadmap, including contributor-friendly tasks where appropriate;
- response and triage practices for bug reports and feature requests;
- review standards for external pull requests;
- release notes that link resolved issues and explain behavior changes;
- a public support path that does not require sharing private contact information;
- respectful requests for adopter feedback only from people who actually use or evaluate the package.

External issues, pull requests, or testimonials count as evidence only when they arise from independent, genuine participation.

### 4. Evidence Ledger

Create a version-controlled evidence ledger that separates facts from interpretation.

The ledger will track:

- release dates and release URLs;
- CI and compatibility evidence;
- package-index and distribution URLs;
- available download or installation metrics, including source and observation date;
- external issues, pull requests, reviews, discussions, and contributors;
- downstream repositories or adopter statements when public or explicitly authorized;
- documentation and outreach URLs;
- maintainer actions such as triage, review, security response, and releases.

Each entry must include an observation date and a source URL. Metrics will be refreshed immediately before the application is drafted and again before submission.

### 5. Application Package

The final application package will contain:

- the ChatGPT-account email supplied by the user;
- the public GitHub username `AikenCod`;
- the public repository URL;
- the truthful role `Primary maintainer`;
- a maximum-500-character project qualification statement grounded in current evidence;
- the user's OpenAI Organization ID;
- a maximum-500-character API-credit use statement describing concrete maintainer automation;
- optional supporting context, limited to facts not already covered;
- a final evidence snapshot and a checklist confirming every claim.

The form may be filled to a reviewable state, but the final submission requires explicit user confirmation because it transmits personal identifiers and creates an external application.

## Proposed API Credit Use

API credits should support the open-source project rather than unrelated private work. Candidate uses are:

- classify and summarize incoming issues for maintainer review;
- propose reproducible test cases from confirmed bug reports;
- draft changelog entries from merged pull requests;
- detect public API documentation drift;
- assist review while preserving human approval for every merge and release.

Automation must not post, close, label, merge, or release without an auditable maintainer-controlled policy.

## Milestones and Gates

### Milestone 1: Technical Trust

Exit when supported builds and tests pass in CI, public compatibility claims are verified, maintenance/security documentation is present, and the `1.0.0` roadmap is public-ready.

### Milestone 2: Distribution Readiness

Exit when clean SPM and CocoaPods consumption is verified, release artifacts and migration notes are consistent, and publication materials are ready for user approval.

### Milestone 3: Real-World Evidence

Exit when the evidence ledger contains independently verifiable adoption or community interaction plus a sustained sequence of legitimate maintainer actions. There is no fabricated numeric threshold. If adoption remains weak after the initial campaign, continue improving the project or use the evidence honestly rather than submitting inflated claims.

### Milestone 4: Application Readiness

Exit when every application claim maps to a current evidence-ledger entry, both 500-character responses meet their limits, required account identifiers are available, and the user has reviewed the complete draft.

### Milestone 5: Submission

Submit only after the user explicitly approves the final form contents and the live form shows no unexpected terms, eligibility restrictions, or sensitive-data requests.

## Verification

Repository changes will be verified with the narrowest relevant tests and a full `swift test` run before release-oriented checkpoints. CI definitions will be validated on GitHub after pushing. Package installation will be tested from clean temporary consumer projects. Documentation links, distribution listings, releases, and metrics will be checked at their authoritative public sources.

Application readiness requires a claim-by-claim audit. A passing test suite alone does not prove adoption, active community maintenance, application submission, or OpenAI acceptance.

## Failure and Adjustment Policy

- If a platform claim cannot be verified, narrow the documented support matrix rather than claiming untested support.
- If distribution publication fails, retain local validation evidence, fix the publishing issue, and do not claim availability.
- If community adoption remains limited, invest in clearer use cases and integrations; do not manufacture interaction.
- If the program terms change, update this design and the application checklist from the live official form.
- If OpenAI rejects or does not select the application, preserve the project improvements and evidence, request feedback when an official channel exists, and reassess before any truthful reapplication.

## Success Definition

Engineering success means `AsyncRequestKit` has stronger verified project quality, distribution, maintenance, and adoption evidence, and a truthful high-quality application has been reviewed and submitted with user approval.

Program success means OpenAI selects the maintainer and grants the six-month ChatGPT Pro benefit. Because that decision is external, the goal remains incomplete until selection and entitlement are verified.
