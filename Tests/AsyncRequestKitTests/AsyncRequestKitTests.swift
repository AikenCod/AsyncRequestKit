import Foundation
import Testing
@testable import AsyncRequestKit

@Suite("AsyncRequestKit")
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
}
