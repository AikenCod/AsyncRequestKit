import Foundation

/// Describes how an asynchronous operation is retried after failures.
public struct RetryPolicy: Sendable {
    /// The delay applied between attempts.
    public enum Delay: Sendable, Equatable {
        /// Retry immediately.
        case none
        /// Wait for a constant duration before every retry.
        case fixed(Duration)
        /// Increase the delay after each failure, optionally limiting and randomizing it.
        case exponentialBackoff(initialDelay: Duration, multiplier: Double, maxDelay: Duration? = nil, jitter: Double = 0)
    }

    /// The total number of attempts, including the initial attempt.
    public let maxAttempts: Int
    /// The delay strategy between attempts.
    public let delay: Delay
    /// A predicate that determines whether a particular error is retryable.
    public let shouldRetry: @Sendable (Error) -> Bool

    /// Creates a retry policy. Values below one for `maxAttempts` are clamped to one.
    public init(
        maxAttempts: Int,
        delay: Delay = .none,
        shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true }
    ) {
        self.maxAttempts = max(1, maxAttempts)
        self.delay = delay
        self.shouldRetry = shouldRetry
    }

    /// Creates a retry policy with a constant delay.
    public static func fixed(
        maxAttempts: Int,
        delay: Duration,
        shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true }
    ) -> RetryPolicy {
        RetryPolicy(maxAttempts: maxAttempts, delay: .fixed(delay), shouldRetry: shouldRetry)
    }

    /// Creates a retry policy with exponential backoff.
    ///
    /// `multiplier` is clamped to at least one and `jitter` to the range `0...1`.
    public static func exponentialBackoff(
        maxAttempts: Int,
        initialDelay: Duration,
        multiplier: Double = 2,
        maxDelay: Duration? = nil,
        jitter: Double = 0,
        shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true }
    ) -> RetryPolicy {
        RetryPolicy(
            maxAttempts: maxAttempts,
            delay: .exponentialBackoff(
                initialDelay: initialDelay,
                multiplier: multiplier,
                maxDelay: maxDelay,
                jitter: jitter
            ),
            shouldRetry: shouldRetry
        )
    }

    /// Runs an operation until it succeeds or the policy declines another attempt.
    ///
    /// Cancellation is checked before each attempt and while waiting between attempts.
    public func run<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        var attempt = 1

        while true {
            try Task.checkCancellation()

            do {
                return try await operation()
            } catch {
                if attempt >= maxAttempts || !shouldRetry(error) {
                    throw error
                }

                let sleepDuration = delayDuration(forAttempt: attempt)
                attempt += 1

                if sleepDuration > .zero {
                    try await Task.sleep(for: sleepDuration)
                }
            }
        }
    }

    private func delayDuration(forAttempt attempt: Int) -> Duration {
        switch delay {
        case .none:
            return .zero
        case .fixed(let duration):
            return duration
        case .exponentialBackoff(let initialDelay, let multiplier, let maxDelay, let jitter):
            let safeMultiplier = max(multiplier, 1)
            let base = Double(initialDelay.asyncRequestKitNanoseconds)
            var nanoseconds = base

            if attempt > 1 {
                for _ in 1..<attempt {
                    nanoseconds = min(nanoseconds * safeMultiplier, Double(UInt64.max))
                }
            }

            if let maxDelay {
                nanoseconds = min(nanoseconds, Double(maxDelay.asyncRequestKitNanoseconds))
            }

            let clampedJitter = min(max(jitter, 0), 1)
            if clampedJitter > 0 {
                let offset = nanoseconds * clampedJitter
                nanoseconds = Double.random(in: (nanoseconds - offset)...(nanoseconds + offset))
            }

            return .asyncRequestKitNanoseconds(UInt64(max(0, nanoseconds)))
        }
    }
}

/// Runs an asynchronous operation using an ad-hoc retry policy.
public func withRetry<T: Sendable>(
    maxAttempts: Int,
    delay: RetryPolicy.Delay = .none,
    shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true },
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await RetryPolicy(
        maxAttempts: maxAttempts,
        delay: delay,
        shouldRetry: shouldRetry
    ).run(operation: operation)
}
