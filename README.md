# AsyncRequestKit

A lightweight Swift Concurrency networking toolkit with first-class support for retry, timeout, request coordination, and controlled parallelism.

## Features

- `HTTPClient` with pluggable transport
- `RetryPolicy` with fixed delay and exponential backoff
- `withTimeout` for async operations
- `withLimitedConcurrency` for bounded parallel work
- `AsyncCache` with actor isolation, TTL, count limit, and request coalescing
- `AsyncQueue` with priority, pause/resume, cancellation, and state tracking

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/your-name/AsyncRequestKit.git", from: "0.1.0")
]
```

## Quick Start

```swift
import AsyncRequestKit

let client = HTTPClient(
    configuration: HTTPClientConfiguration(
        retryPolicy: .fixed(maxAttempts: 3, delay: .milliseconds(200)),
        timeout: .seconds(5)
    )
)
```

### Retry

```swift
let payload = try await withRetry(maxAttempts: 3, delay: .fixed(.milliseconds(200))) {
    try await client.data(for: request)
}
```

### Timeout

```swift
let value = try await withTimeout(.seconds(2)) {
    try await client.send(request)
}
```

### AsyncCache

```swift
let cache = AsyncCache<String, Data>(ttl: .minutes(5), countLimit: 200)

let data = try await cache.value(for: request.url!.absoluteString) {
    try await client.data(for: request)
}
```

### AsyncQueue

```swift
let queue = AsyncQueue(maxConcurrentTasks: 2)

let job = await queue.add(priority: .high) {
    try await client.data(for: request)
}

let data = try await job.value
```

## Testing

```bash
swift test
```
