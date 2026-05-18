import Foundation
import Testing
@testable import AsyncRequestKit

@Suite("AsyncRequestKit", .serialized)
struct AsyncRequestKitTests {
    @Test("withTimeout returns the operation result")
    func timeoutReturnsResult() async throws {
        let value = try await withTimeout(.milliseconds(200)) {
            try await Task.sleep(for: .milliseconds(20))
            return 42
        }

        #expect(value == 42)
    }

    @Test("withTimeout throws when the deadline is exceeded")
    func timeoutThrows() async {
        await #expect(throws: TimeoutError.self) {
            try await withTimeout(.milliseconds(30)) {
                try await Task.sleep(for: .milliseconds(200))
                return 1
            }
        }
    }

    @Test("withTimeout returns even when the operation never cooperates with cancellation")
    func timeoutReturnsForNonCooperativeOperation() async {
        await #expect(throws: TimeoutError.self) {
            try await withTimeout(.milliseconds(30)) {
                try await withUnsafeThrowingContinuation { (_: UnsafeContinuation<Int, Error>) in
                }
            }
        }
    }

    @Test("RetryPolicy retries until success")
    func retryEventuallySucceeds() async throws {
        actor Counter {
            var value = 0
            func increment() -> Int {
                value += 1
                return value
            }
        }

        struct SampleError: Error {}

        let counter = Counter()
        let result = try await withRetry(maxAttempts: 3, delay: .fixed(.milliseconds(1))) {
            if await counter.increment() < 3 {
                throw SampleError()
            }
            return "ok"
        }

        #expect(result == "ok")
    }

    @Test("Limited concurrency preserves input order")
    func limitedConcurrencyPreservesOrder() async throws {
        actor Tracker {
            var running = 0
            var maximum = 0

            func started() {
                running += 1
                maximum = max(maximum, running)
            }

            func finished() {
                running -= 1
            }

            func maxRunning() -> Int {
                maximum
            }
        }

        let tracker = Tracker()
        let values = try await withLimitedConcurrency(maxConcurrentTasks: 2, items: [1, 2, 3, 4]) { value in
            await tracker.started()
            try await Task.sleep(for: .milliseconds(20))
            await tracker.finished()
            return value * 10
        }

        #expect(values == [10, 20, 30, 40])
        #expect(await tracker.maxRunning() == 2)
    }

    @Test("AsyncCache coalesces concurrent loads")
    func cacheCoalescesLoads() async throws {
        actor Counter {
            var calls = 0
            func increment() -> Int {
                calls += 1
                return calls
            }

            func totalCalls() -> Int {
                calls
            }
        }

        let counter = Counter()
        let cache = AsyncCache<String, Int>(ttl: .seconds(1), countLimit: 10)

        async let first = cache.value(for: "user") {
            _ = await counter.increment()
            try await Task.sleep(for: .milliseconds(40))
            return 7
        }

        async let second = cache.value(for: "user") {
            _ = await counter.increment()
            return 9
        }

        let values = try await [first, second]
        #expect(values[0] == values[1])
        #expect(await counter.totalCalls() == 1)
    }

    @Test("AsyncQueue respects priority and cancellation")
    func queuePriorityAndCancellation() async throws {
        let queue = AsyncQueue(maxConcurrentTasks: 1)
        await queue.pause()

        let low = await queue.add(priority: .low) { "low" }
        let high = await queue.add(priority: .high) { "high" }
        let cancelled = await queue.add(priority: .normal) {
            try await Task.sleep(for: .seconds(1))
            return "cancelled"
        }

        await cancelled.cancel()
        await queue.resume()

        let first = try await high.value
        let second = try await low.value

        #expect(first == "high")
        #expect(second == "low")
        #expect(await high.state == .succeeded)
        #expect(await low.state == .succeeded)
        #expect(await cancelled.state == .cancelled)

        await #expect(throws: CancellationError.self) {
            _ = try await cancelled.value
        }
    }

    @Test("AsyncQueue keeps cancelled state for running jobs")
    func queueRunningCancellationIsTerminal() async throws {
        let queue = AsyncQueue(maxConcurrentTasks: 1)

        let job = await queue.add {
            try? await Task.sleep(for: .milliseconds(20))
            return "finished"
        }

        try? await Task.sleep(for: .milliseconds(5))
        await job.cancel()

        await #expect(throws: CancellationError.self) {
            _ = try await job.value
        }

        #expect(await job.state == .cancelled)
    }

    @Test("HTTPClient retries and decodes payloads")
    func httpClientRetriesAndDecodes() async throws {
        actor Counter {
            var calls = 0
            func next() -> Int {
                calls += 1
                return calls
            }

            func totalCalls() -> Int {
                calls
            }
        }

        struct Payload: Codable, Equatable {
            let value: Int
        }

        let counter = Counter()
        let client = HTTPClient(
            configuration: HTTPClientConfiguration(
                retryPolicy: .fixed(maxAttempts: 3, delay: .milliseconds(1)),
                timeout: .seconds(1)
            ),
            transport: { request in
                let attempt = await counter.next()
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com")!,
                    statusCode: attempt < 2 ? 500 : 200,
                    httpVersion: nil,
                    headerFields: nil
                )!

                let data = if attempt < 2 {
                    Data("fail".utf8)
                } else {
                    try JSONEncoder().encode(Payload(value: 99))
                }

                return (data, response)
            }
        )

        let payload: Payload = try await client.get(URL(string: "https://example.com/test")!)
        #expect(payload == Payload(value: 99))
        #expect(await counter.totalCalls() == 2)
    }

    @Test("HTTPClient encodes Encodable request bodies as JSON")
    func httpClientEncodesJSONBodies() async throws {
        struct RequestBody: Codable, Equatable {
            let name: String
            let enabled: Bool
        }

        let expectedBody = RequestBody(name: "demo", enabled: true)
        let client = HTTPClient(
            transport: { request in
                #expect(request.httpMethod == "POST")
                #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
                #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")

                let decodedBody = try JSONDecoder().decode(
                    RequestBody.self,
                    from: try #require(request.httpBody)
                )
                #expect(decodedBody == expectedBody)

                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!

                return (Data("{}".utf8), response)
            }
        )

        var request = URLRequest(url: URL(string: "https://example.com/items")!)
        request.httpMethod = "POST"

        _ = try await client.data(for: request, body: expectedBody)
    }

    @Test("HTTPClient post encodes request and decodes response")
    func httpClientPostRoundTrip() async throws {
        struct RequestBody: Codable, Equatable {
            let name: String
        }

        struct ResponseBody: Codable, Equatable {
            let id: Int
            let name: String
        }

        let client = HTTPClient(
            transport: { request in
                #expect(request.httpMethod == "POST")
                #expect(request.value(forHTTPHeaderField: "X-Trace-ID") == "123")

                let body = try JSONDecoder().decode(
                    RequestBody.self,
                    from: try #require(request.httpBody)
                )
                #expect(body == RequestBody(name: "created"))

                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!

                let payload = try JSONEncoder().encode(ResponseBody(id: 7, name: body.name))
                return (payload, response)
            }
        )

        let response: ResponseBody = try await client.post(
            URL(string: "https://example.com/items")!,
            body: RequestBody(name: "created"),
            headers: ["X-Trace-ID": "123"]
        )

        #expect(response == ResponseBody(id: 7, name: "created"))
    }

    @Test("HTTPClient resolves relative paths from baseURL")
    func httpClientResolvesBaseURLPaths() async throws {
        struct ResponseBody: Codable, Equatable {
            let ok: Bool
        }

        let client = HTTPClient(
            configuration: HTTPClientConfiguration(
                baseURL: URL(string: "https://api.example.com/v1")!
            ),
            transport: { request in
                #expect(request.url?.absoluteString == "https://api.example.com/v1/users/42")
                #expect(request.httpMethod == "GET")

                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!

                return (try JSONEncoder().encode(ResponseBody(ok: true)), response)
            }
        )

        let response: ResponseBody = try await client.get("/users/42")
        #expect(response == ResponseBody(ok: true))
    }

    @Test("HTTPClient applies default headers and allows per-request overrides")
    func httpClientAppliesDefaultHeaders() async throws {
        struct RequestBody: Codable, Equatable {
            let name: String
        }

        struct ResponseBody: Codable, Equatable {
            let ok: Bool
        }

        let client = HTTPClient(
            configuration: HTTPClientConfiguration(
                baseURL: URL(string: "https://api.example.com")!,
                defaultHeaders: [
                    "Authorization": "Bearer default-token",
                    "X-Client": "AsyncRequestKit"
                ]
            ),
            transport: { request in
                #expect(request.url?.absoluteString == "https://api.example.com/users")
                #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer override-token")
                #expect(request.value(forHTTPHeaderField: "X-Client") == "AsyncRequestKit")

                let body = try JSONDecoder().decode(
                    RequestBody.self,
                    from: try #require(request.httpBody)
                )
                #expect(body == RequestBody(name: "Aiken"))

                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!

                return (try JSONEncoder().encode(ResponseBody(ok: true)), response)
            }
        )

        let response: ResponseBody = try await client.post(
            "/users",
            body: RequestBody(name: "Aiken"),
            headers: ["Authorization": "Bearer override-token"]
        )

        #expect(response == ResponseBody(ok: true))
    }

    @Test("AK uses shared configuration for path-based requests")
    func akUsesSharedConfiguration() async throws {
        struct ResponseBody: Codable, Equatable {
            let id: Int
        }

        await AK.use(
            HTTPClient(
                configuration: HTTPClientConfiguration(
                    baseURL: URL(string: "https://api.example.com/v2")!,
                    defaultHeaders: ["Authorization": "Bearer shared-token"]
                ),
                transport: { request in
                    #expect(request.url?.absoluteString == "https://api.example.com/v2/users/9")
                    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer shared-token")

                    let response = HTTPURLResponse(
                        url: try #require(request.url),
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!

                    return (try JSONEncoder().encode(ResponseBody(id: 9)), response)
                }
            )
        )
        defer {
            Task {
                await AK.reset()
            }
        }

        let response: ResponseBody = try await AK.get("/users/9")
        #expect(response == ResponseBody(id: 9))
    }

    @Test("AK reset clears shared configuration")
    func akResetClearsSharedConfiguration() async throws {
        await AK.configure(
            HTTPClientConfiguration(
                baseURL: URL(string: "https://api.example.com")!
            )
        )
        await AK.reset()

        await #expect(throws: URLError.self) {
            let _: String = try await AK.get("/users/1")
        }
    }

    @Test("HTTPClient interceptor refreshes token and retries unauthorized requests")
    func httpClientInterceptorRefreshesToken() async throws {
        actor TokenStore {
            private var token: String

            init(token: String) {
                self.token = token
            }

            func currentToken() -> String {
                token
            }

            func update(token: String) {
                self.token = token
            }
        }

        actor RefreshCounter {
            private var count = 0

            func increment() {
                count += 1
            }

            func total() -> Int {
                count
            }
        }

        struct AuthInterceptor: HTTPInterceptor {
            let tokenStore: TokenStore
            let coordinator: TokenRefreshCoordinator<String>
            let refresh: @Sendable () async throws -> String

            func adapt(_ request: URLRequest) async throws -> URLRequest {
                var request = request
                let token = await tokenStore.currentToken()
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

                let token = try await coordinator.refresh(refresh)
                await tokenStore.update(token: token)
                return .retry
            }
        }

        struct ResponseBody: Codable, Equatable {
            let ok: Bool
        }

        actor RequestCounter {
            private var count = 0

            func next() -> Int {
                count += 1
                return count
            }
        }

        let tokenStore = TokenStore(token: "expired-token")
        let refreshCounter = RefreshCounter()
        let requestCounter = RequestCounter()
        let interceptor = AuthInterceptor(
            tokenStore: tokenStore,
            coordinator: TokenRefreshCoordinator<String>(),
            refresh: {
                await refreshCounter.increment()
                return "fresh-token"
            }
        )

        let client = HTTPClient(
            configuration: HTTPClientConfiguration(
                baseURL: URL(string: "https://api.example.com")!,
                interceptors: [interceptor],
                interceptorRetryLimit: 1
            ),
            transport: { request in
                let attempt = await requestCounter.next()
                let token = request.value(forHTTPHeaderField: "Authorization")
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com")!,
                    statusCode: attempt == 1 ? 401 : 200,
                    httpVersion: nil,
                    headerFields: nil
                )!

                if attempt == 1 {
                    #expect(token == "Bearer expired-token")
                    return (Data("unauthorized".utf8), response)
                }

                #expect(token == "Bearer fresh-token")
                return (try JSONEncoder().encode(ResponseBody(ok: true)), response)
            }
        )

        let response: ResponseBody = try await client.get("/profile")
        #expect(response == ResponseBody(ok: true))
        #expect(await refreshCounter.total() == 1)
    }

    @Test("TokenRefreshCoordinator coalesces concurrent refresh work")
    func tokenRefreshCoordinatorCoalescesConcurrentWork() async throws {
        actor Counter {
            private var count = 0

            func increment() {
                count += 1
            }

            func total() -> Int {
                count
            }
        }

        let counter = Counter()
        let coordinator = TokenRefreshCoordinator<String>()

        async let first = coordinator.refresh {
            await counter.increment()
            try await Task.sleep(for: .milliseconds(20))
            return "shared-token"
        }

        async let second = coordinator.refresh {
            await counter.increment()
            try await Task.sleep(for: .milliseconds(20))
            return "shared-token"
        }

        async let third = coordinator.refresh {
            await counter.increment()
            try await Task.sleep(for: .milliseconds(20))
            return "shared-token"
        }

        let values = try await [first, second, third]
        #expect(values == ["shared-token", "shared-token", "shared-token"])
        #expect(await counter.total() == 1)
    }
}
