# Adoption Checklist

Use this checklist before introducing AsyncRequestKit into a production target.

## Compatibility

- [ ] Confirm the target supports macOS 13, iOS 16, tvOS 16, or watchOS 9 or later.
- [ ] Confirm the package can be compiled in the target's Swift 6 language mode.
- [ ] Build and test the exact tagged version with your Xcode and CI toolchains.
- [ ] Review `CHANGELOG.md` before updating because source compatibility is not promised across every `0.x` minor release.

## Requests and reliability

- [ ] Decide whether dependencies should own an `HTTPClient` or intentionally share `AK`.
- [ ] Verify base-URL resolution, default headers, decoding, and non-2xx error handling against the real service.
- [ ] Apply `RetryPolicy` only where retrying is safe; use idempotency keys for retryable writes when the service supports them.
- [ ] Test timeout and caller-cancellation behavior, including operations that are slow to cooperate with cancellation.
- [ ] Set finite interceptor retry limits and confirm repeated authorization failures terminate.

## Authentication

- [ ] Keep mutable credentials actor isolated or otherwise concurrency safe.
- [ ] Ensure token refresh does not pass through the interceptor that initiated it.
- [ ] Test overlapping 401 responses, refresh failure, repeated 401 responses, logout, and cancellation.
- [ ] Confirm the server's token rotation and revocation rules match the local update order.

## Uploads

- [ ] Confirm every multipart field name, filename, MIME type, and response schema with the server contract.
- [ ] Set an upload timeout and test service-side size errors.
- [ ] Keep uploads small enough for the original fields and complete encoded body to coexist in memory.
- [ ] Choose a different transport when streaming, resumable, or background uploads are required.

## Migration and operations

- [ ] Wrap the package behind an application-owned boundary if future migration cost is material.
- [ ] Add transport-stub unit tests for critical request construction and response handling.
- [ ] Add end-to-end tests for the service behaviors a stub cannot prove.
- [ ] Review the license, security policy, maintenance activity, and open issues before each upgrade.
