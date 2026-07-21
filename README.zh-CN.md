# AsyncRequestKit

[English](README.md) | [简体中文](README.zh-CN.md)

一个轻量级的 Swift Concurrency 网络工具库，提供开箱即用的重试、超时、请求协作、受控并发，以及共享客户端体验。

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
- 支持读取响应元信息的 `HTTPResponse<Value>` 和空响应场景的 `EmptyResponse`

## 安装

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

## 快速开始

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

## 请求方式

### 共享客户端

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

### 通用请求入口

```swift
let user: User = try await AK.request("/users/1", method: "GET")

let created: User = try await AK.request(
    "/users",
    method: "POST",
    body: CreateUser(name: "Aiken")
)
```

### 读取响应元信息

```swift
let response: HTTPResponse<User> = try await AK.requestResponse(
    "/users/1",
    method: "GET"
)

print(response.response.statusCode)
print(response.response.value(forHTTPHeaderField: "ETag") ?? "")
```

### 空响应

```swift
try await AK.delete("/users/1")

let empty: EmptyResponse = try await AK.delete("/users/1")
```

### 字典参数

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

### Codable 请求体

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

### 小文件上传

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

## 重试与超时

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

## Token 刷新示例

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

当多个请求同时因为 `401` 失败时，`TokenRefreshCoordinator` 会保证只发起一次刷新请求，其他请求等待同一个刷新结果，token 更新后再自动重试。

## Demo

仓库里包含两个可运行 demo，底层都使用 [JSONPlaceholder](https://jsonplaceholder.typicode.com/)。

### Xcode 示例工程

直接打开 [AsyncRequestKitDemoApp.xcodeproj](Examples/AsyncRequestKitDemoApp/AsyncRequestKitDemoApp.xcodeproj)。

### 命令行示例

```bash
swift run AsyncRequestKitDemo
```

## 测试

```bash
swift test
```

## 项目资源

- [API 文档源文件](Sources/AsyncRequestKit/AsyncRequestKit.docc/AsyncRequestKit.md)
- [更新日志](CHANGELOG.md)
- [贡献指南](CONTRIBUTING.md)
- [安全策略](SECURITY.md)
- [路线图](ROADMAP.md)

## 许可证

AsyncRequestKit 基于 MIT 许可证发布，详情请参阅 [LICENSE](LICENSE)。
