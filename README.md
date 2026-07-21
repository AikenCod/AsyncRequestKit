# AsyncRequestKit

[English](README.md) | [简体中文](README.zh-CN.md)

A lightweight Swift Concurrency networking toolkit with first-class support for retry, timeout, request coordination, controlled parallelism, and shared-client ergonomics.

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
- `HTTPResponse<Value>` and `EmptyResponse` for metadata-aware and no-content flows

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/AikenCod/AsyncRequestKit.git", from: "0.4.0")
]
```

### CocoaPods

```ruby
pod 'AsyncRequestKit', '~> 0.4'
```

## Quick Start

```swift
import AsyncRequestKit
import Foundation

struct User: Decodable {
    let id: Int
    let name: String
}

struct CreateUser: Encodable {
    let name: String
}

await AK.configure(
    HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        defaultHeaders: ["Accept": "application/json"]
    )
)

let user: User = try await AK.get("/users/1")

let created: User = try await AK.post(
    "/users",
    body: CreateUser(name: "Aiken")
)

let page: [User] = try await AK.get(
    "/users",
    parameters: ["page": 2]
)
```

## Request APIs

### Shared Client

```swift
await AK.configure(
    HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        defaultHeaders: ["Authorization": "Bearer <token>"]
    )
)

let sharedClient = await AK.shared
let user: User = try await sharedClient.get("/users/1")
```

### Generic Requests

```swift
let user: User = try await AK.request("/users/1", method: "GET")

let created: User = try await AK.request(
    "/users",
    method: "POST",
    body: CreateUser(name: "Aiken")
)
```

### Response Metadata

```swift
let response: HTTPResponse<User> = try await AK.requestResponse(
    "/users/1",
    method: "GET"
)

print(response.response.statusCode)
print(response.response.value(forHTTPHeaderField: "ETag") ?? "")
```

### Empty Responses

```swift
try await AK.delete("/users/1")

let empty: EmptyResponse = try await AK.delete("/users/1")
```

### Dictionary Parameters

```swift
let created: Post = try await AK.post(
    "/posts",
    parameters: [
        "title": "Hello",
        "body": "World",
        "userId": 1
    ],
    encoding: JSONEncoding.default
)

let users: [User] = try await AK.get(
    "/users",
    parameters: [
        "page": 2,
        "include": ["posts", "profile"]
    ]
)
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

let user: User = try await AK.post(
    "/users",
    body: CreateUser(name: "Aiken")
)
```

### Small File Uploads

```swift
struct UploadResult: Decodable {
    let url: String
}

let result: UploadResult = try await AK.upload(
    "/avatar",
    multipart: { form in
        form.append("user-1", name: "userId")
        form.append(
            imageData,
            name: "file",
            fileName: "avatar.jpg",
            mimeType: "image/jpeg"
        )
    }
)
```

## Retry And Timeout

```swift
let payload = try await withRetry(maxAttempts: 3, delay: .fixed(.milliseconds(200))) {
    try await client.data(for: request)
}

let value = try await withTimeout(.seconds(2)) {
    try await client.send(request)
}
```

## AsyncCache

```swift
let cache = AsyncCache<String, Data>(ttl: .minutes(5), countLimit: 200)

let data = try await cache.value(for: request.url!.absoluteString) {
    try await client.data(for: request)
}
```

## AsyncQueue

```swift
let queue = AsyncQueue(maxConcurrentTasks: 2)

let job = await queue.add(priority: .high) {
    try await client.data(for: request)
}

let data = try await job.value
```

## Token Refresh Demo

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

When several requests fail with `401` at the same time, `TokenRefreshCoordinator` ensures only one refresh request runs. The others wait for the same result and retry after the token is updated.

## Demo

The repository includes two runnable demos backed by [JSONPlaceholder](https://jsonplaceholder.typicode.com/).

### Xcode Demo App

Open [AsyncRequestKitDemoApp.xcodeproj](Examples/AsyncRequestKitDemoApp/AsyncRequestKitDemoApp.xcodeproj) in Xcode.

### Command Line Demo

```bash
swift run AsyncRequestKitDemo
```

## Testing

```bash
swift test
```

## License

AsyncRequestKit is available under the MIT License. See [LICENSE](LICENSE).
