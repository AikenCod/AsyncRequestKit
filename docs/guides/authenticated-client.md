# Authenticated HTTP Client

This guide builds a bearer-token client with `HTTPInterceptor` and
`TokenRefreshCoordinator`. The token store is actor isolated, overlapping 401
responses share one refresh task, and the client performs at most one
interceptor-directed retry.

## Complete setup

```swift
import AsyncRequestKit
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

actor TokenStore {
    private var accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
    }

    func current() -> String {
        accessToken
    }

    func update(_ accessToken: String) {
        self.accessToken = accessToken
    }
}

struct AuthInterceptor: HTTPInterceptor {
    let tokenStore: TokenStore
    let coordinator: TokenRefreshCoordinator<String>
    let refreshAccessToken: @Sendable () async throws -> String

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var request = request
        let token = await tokenStore.current()
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

        let token = try await coordinator.refresh(refreshAccessToken)
        await tokenStore.update(token)
        return .retry
    }
}

let tokenStore = TokenStore(accessToken: "expired-token")
let interceptor = AuthInterceptor(
    tokenStore: tokenStore,
    coordinator: TokenRefreshCoordinator<String>(),
    refreshAccessToken: {
        // Replace this closure with a refresh-token request that does not use
        // the same AuthInterceptor, otherwise a 401 can recurse.
        "fresh-token"
    }
)

let client = HTTPClient(
    configuration: HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        timeout: .seconds(15),
        interceptors: [interceptor],
        interceptorRetryLimit: 1
    )
)
```

`interceptorRetryLimit` limits retries requested by interceptors. With a value
of `1`, the first 401 may refresh and retry once; a second 401 is returned as
`HTTPClientError.unacceptableStatusCode`. Keep this limit finite, and retry
only requests that your server treats safely.

`TokenRefreshCoordinator` shares an in-progress refresh among overlapping
callers. It does not permanently cache the token, so `TokenStore` remains the
source of truth. Cancelling one waiter does not promise to cancel the shared
refresh task; make the refresh closure cancellation-aware and let request-level
timeouts bound the work.

## Test without the network

Inject `HTTPClient.Transport` to assert both authorization attempts:

```swift
actor AttemptCounter {
    private var value = 0

    func next() -> Int {
        value += 1
        return value
    }
}

struct Profile: Codable, Equatable {
    let id: Int
}

let attempts = AttemptCounter()
let testClient = HTTPClient(
    configuration: HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        interceptors: [interceptor],
        interceptorRetryLimit: 1
    ),
    transport: { request in
        let attempt = await attempts.next()
        let status = attempt == 1 ? 401 : 200
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: status,
            httpVersion: nil,
            headerFields: nil
        )!

        if status == 401 {
            precondition(
                request.value(forHTTPHeaderField: "Authorization") ==
                    "Bearer expired-token"
            )
            return (Data("unauthorized".utf8), response)
        }

        precondition(
            request.value(forHTTPHeaderField: "Authorization") ==
                "Bearer fresh-token"
        )
        return (try JSONEncoder().encode(Profile(id: 1)), response)
    }
)

let profile: Profile = try await testClient.get("/profile")
precondition(profile == Profile(id: 1))
```

Also test refresh failure, a repeated 401, caller cancellation, and several
simultaneous requests before adopting this pattern in production.
