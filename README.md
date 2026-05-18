# AsyncRequestKit

A lightweight Swift Concurrency networking toolkit with first-class support for retry, timeout, request coordination, and controlled parallelism.

一个轻量级的 Swift Concurrency 网络工具库，提供开箱即用的重试、超时、请求协作与受控并发能力。

## Features

- `HTTPClient` with pluggable transport
- `RetryPolicy` with fixed delay and exponential backoff
- `withTimeout` for async operations
- `withLimitedConcurrency` for bounded parallel work
- `AsyncCache` with actor isolation, TTL, count limit, and request coalescing
- `AsyncQueue` with priority, pause/resume, cancellation, and state tracking

## 特性

- 可插拔传输层的 `HTTPClient`
- 支持固定延迟与指数退避的 `RetryPolicy`
- 用于异步操作的 `withTimeout`
- 用于限制并发数的 `withLimitedConcurrency`
- 具备 actor 隔离、TTL、数量限制和请求合并能力的 `AsyncCache`
- 支持优先级、暂停/恢复、取消和状态跟踪的 `AsyncQueue`

## Installation

```swift
dependencies: [
    .package(url: "git@github.com:AikenCod/AsyncRequestKit.git", from: "0.1.0")
]
```

## 安装

```swift
dependencies: [
    .package(url: "git@github.com:AikenCod/AsyncRequestKit.git", from: "0.1.0")
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

## 快速开始

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

## 测试

```bash
swift test
```
