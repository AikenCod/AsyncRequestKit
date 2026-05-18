# AsyncRequestKit

A lightweight Swift Concurrency networking toolkit with first-class support for retry, timeout, request coordination, and controlled parallelism.

一个轻量级的 Swift Concurrency 网络工具库，提供开箱即用的重试、超时、请求协作与受控并发能力。

## Features

- `HTTPClient` with pluggable transport
- `AK` shared client facade for Alamofire-style usage
- `RetryPolicy` with fixed delay and exponential backoff
- `withTimeout` for async operations
- `withLimitedConcurrency` for bounded parallel work
- `AsyncCache` with actor isolation, TTL, count limit, and request coalescing
- `AsyncQueue` with priority, pause/resume, cancellation, and state tracking
- `HTTPInterceptor` hooks for adapting requests and retrying after failures
- `TokenRefreshCoordinator` for coalescing concurrent token refresh work

## 特性

- 可插拔传输层的 `HTTPClient`
- 类似 Alamofire 风格的共享入口 `AK`
- 支持固定延迟与指数退避的 `RetryPolicy`
- 用于异步操作的 `withTimeout`
- 用于限制并发数的 `withLimitedConcurrency`
- 具备 actor 隔离、TTL、数量限制和请求合并能力的 `AsyncCache`
- 支持优先级、暂停/恢复、取消和状态跟踪的 `AsyncQueue`
- 用于请求改写与失败重试的 `HTTPInterceptor`
- 用于合并并发 token 刷新的 `TokenRefreshCoordinator`

## Installation

```swift
dependencies: [
    .package(url: "git@github.com:AikenCod/AsyncRequestKit.git", from: "0.2.0")
]
```

## 安装

```swift
dependencies: [
    .package(url: "git@github.com:AikenCod/AsyncRequestKit.git", from: "0.2.0")
]
```

## Quick Start

```swift
import AsyncRequestKit
import Foundation

actor TokenStore {
    private var accessToken = "expired-token"

    func token() -> String {
        accessToken
    }

    func update(token: String) {
        accessToken = token
    }
}

struct AuthInterceptor: HTTPInterceptor {
    let tokenStore: TokenStore
    let coordinator: TokenRefreshCoordinator<String>

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        let token = await tokenStore.token()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> HTTPRetryDecision {
        guard response?.statusCode == 401 else {
            return .doNotRetry
        }

        let freshToken = try await coordinator.refresh {
            let refreshed = try await refreshTokenFromServer()
            await tokenStore.update(token: refreshed.accessToken)
            return refreshed.accessToken
        }

        await tokenStore.update(token: freshToken)
        return .retry
    }
}

let tokenStore = TokenStore()

await AK.configure(
    HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        defaultHeaders: [
            "X-App-Version": "1.0.0"
        ],
        interceptors: [
            AuthInterceptor(
                tokenStore: tokenStore,
                coordinator: TokenRefreshCoordinator<String>()
            )
        ],
        interceptorRetryLimit: 1,
        retryPolicy: .fixed(maxAttempts: 3, delay: .milliseconds(200)),
        timeout: .seconds(5)
    )
)

let profile: User = try await AK.get("/me")
```

## 快速开始

```swift
import AsyncRequestKit
import Foundation

actor TokenStore {
    private var accessToken = "expired-token"

    func token() -> String {
        accessToken
    }

    func update(token: String) {
        accessToken = token
    }
}

struct AuthInterceptor: HTTPInterceptor {
    let tokenStore: TokenStore
    let coordinator: TokenRefreshCoordinator<String>

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        let token = await tokenStore.token()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> HTTPRetryDecision {
        guard response?.statusCode == 401 else {
            return .doNotRetry
        }

        let freshToken = try await coordinator.refresh {
            let refreshed = try await refreshTokenFromServer()
            await tokenStore.update(token: refreshed.accessToken)
            return refreshed.accessToken
        }

        await tokenStore.update(token: freshToken)
        return .retry
    }
}

let tokenStore = TokenStore()

await AK.configure(
    HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        defaultHeaders: [
            "X-App-Version": "1.0.0"
        ],
        interceptors: [
            AuthInterceptor(
                tokenStore: tokenStore,
                coordinator: TokenRefreshCoordinator<String>()
            )
        ],
        interceptorRetryLimit: 1,
        retryPolicy: .fixed(maxAttempts: 3, delay: .milliseconds(200)),
        timeout: .seconds(5)
    )
)

let profile: User = try await AK.get("/me")
```

### Shared Client

```swift
await AK.configure(
    HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        defaultHeaders: ["Authorization": "Bearer <token>"]
    )
)

let user: User = try await AK.get("/users/1")
```

### 共享客户端

```swift
await AK.configure(
    HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        defaultHeaders: ["Authorization": "Bearer <token>"]
    )
)

let user: User = try await AK.get("/users/1")
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

### Codable Request Body

```swift
struct CreateUser: Codable {
    let name: String
}

struct User: Codable {
    let id: Int
    let name: String
}

let user: User = try await client.post(
    "/users",
    body: CreateUser(name: "Aiken")
)
```

### Codable 请求体

```swift
struct CreateUser: Codable {
    let name: String
}

struct User: Codable {
    let id: Int
    let name: String
}

let user: User = try await client.post(
    "/users",
    body: CreateUser(name: "Aiken")
)
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

### Auth Refresh Demo

```swift
import AsyncRequestKit
import Foundation

actor TokenStore {
    private var accessToken = "expired-token"

    func token() -> String {
        accessToken
    }

    func update(token: String) {
        accessToken = token
    }
}

struct AuthInterceptor: HTTPInterceptor {
    let tokenStore: TokenStore
    let coordinator: TokenRefreshCoordinator<String>

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        let token = await tokenStore.token()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> HTTPRetryDecision {
        guard response?.statusCode == 401 else {
            return .doNotRetry
        }

        let freshToken = try await coordinator.refresh {
            let refreshed = try await refreshTokenFromServer()
            await tokenStore.update(token: refreshed.accessToken)
            return refreshed.accessToken
        }

        await tokenStore.update(token: freshToken)
        return .retry
    }
}

let tokenStore = TokenStore()
let authInterceptor = AuthInterceptor(
    tokenStore: tokenStore,
    coordinator: TokenRefreshCoordinator<String>()
)

await AK.configure(
    HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        interceptors: [authInterceptor],
        interceptorRetryLimit: 1
    )
)

let profile: User = try await AK.get("/me")
```

When several requests fail with `401` at the same time, `TokenRefreshCoordinator`
ensures only one refresh request runs. The others wait for the same result and retry
after the token is updated.

### Token 刷新示例

```swift
import AsyncRequestKit
import Foundation

actor TokenStore {
    private var accessToken = "expired-token"

    func token() -> String {
        accessToken
    }

    func update(token: String) {
        accessToken = token
    }
}

struct AuthInterceptor: HTTPInterceptor {
    let tokenStore: TokenStore
    let coordinator: TokenRefreshCoordinator<String>

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        let token = await tokenStore.token()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> HTTPRetryDecision {
        guard response?.statusCode == 401 else {
            return .doNotRetry
        }

        let freshToken = try await coordinator.refresh {
            let refreshed = try await refreshTokenFromServer()
            await tokenStore.update(token: refreshed.accessToken)
            return refreshed.accessToken
        }

        await tokenStore.update(token: freshToken)
        return .retry
    }
}

let tokenStore = TokenStore()
let authInterceptor = AuthInterceptor(
    tokenStore: tokenStore,
    coordinator: TokenRefreshCoordinator<String>()
)

await AK.configure(
    HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        interceptors: [authInterceptor],
        interceptorRetryLimit: 1
    )
)

let profile: User = try await AK.get("/me")
```

当多个请求同时因为 `401` 失败时，`TokenRefreshCoordinator` 会保证只发起一次
刷新请求，其他请求等待同一个刷新结果，token 更新后再自动重试。

## Testing

```bash
swift test
```

## 测试

```bash
swift test
```
