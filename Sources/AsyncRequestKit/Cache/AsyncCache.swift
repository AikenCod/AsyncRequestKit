/// Controls expiration and capacity for an ``AsyncCache``.
public struct CachePolicy: Sendable, Equatable {
    /// The lifetime of each cached value, or `nil` for no time-based expiration.
    public let ttl: Duration?
    /// The maximum number of values, or `nil` for no count limit.
    public let countLimit: Int?

    /// Creates a cache policy.
    public init(ttl: Duration? = nil, countLimit: Int? = nil) {
        self.ttl = ttl
        self.countLimit = countLimit
    }
}

private struct CacheEntry<Value: Sendable>: Sendable {
    let value: Value
    let expiresAt: ContinuousClock.Instant?
    var lastAccessedAt: ContinuousClock.Instant

    func isExpired(now: ContinuousClock.Instant) -> Bool {
        guard let expiresAt else {
            return false
        }
        return now >= expiresAt
    }
}

/// An actor-isolated cache that coalesces concurrent loads for the same key.
public actor AsyncCache<Key: Hashable & Sendable, Value: Sendable> {
    private let policy: CachePolicy
    private let clock = ContinuousClock()
    private var storage: [Key: CacheEntry<Value>] = [:]
    private var inFlightTasks: [Key: Task<Value, Error>] = [:]

    /// Creates a cache with the supplied policy.
    public init(policy: CachePolicy = CachePolicy()) {
        self.policy = policy
    }

    /// Creates a cache from expiration and capacity values.
    public init(ttl: Duration? = nil, countLimit: Int? = nil) {
        self.policy = CachePolicy(ttl: ttl, countLimit: countLimit)
    }

    /// Returns a cached value or loads it once for all concurrent callers of the key.
    ///
    /// Failed loads are not cached.
    public func value(
        for key: Key,
        loader: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        let now = clock.now

        if var entry = storage[key], !entry.isExpired(now: now) {
            entry.lastAccessedAt = now
            storage[key] = entry
            return entry.value
        }

        storage[key] = nil

        if let task = inFlightTasks[key] {
            return try await task.value
        }

        let task = Task {
            try await loader()
        }
        inFlightTasks[key] = task

        do {
            let loadedValue = try await task.value
            inFlightTasks[key] = nil
            insert(loadedValue, for: key, now: clock.now)
            return loadedValue
        } catch {
            inFlightTasks[key] = nil
            throw error
        }
    }

    /// Inserts or replaces a value.
    public func setValue(_ value: Value, for key: Key) {
        insert(value, for: key, now: clock.now)
    }

    /// Removes a value and cancels an in-flight load for the key.
    public func removeValue(for key: Key) {
        storage[key] = nil
        inFlightTasks[key]?.cancel()
        inFlightTasks[key] = nil
    }

    /// Removes all values and cancels all in-flight loads.
    public func removeAll() {
        storage.removeAll()
        for task in inFlightTasks.values {
            task.cancel()
        }
        inFlightTasks.removeAll()
    }

    /// Returns a currently valid cached value without invoking a loader.
    public func cachedValue(for key: Key) -> Value? {
        let now = clock.now
        guard var entry = storage[key], !entry.isExpired(now: now) else {
            storage[key] = nil
            return nil
        }

        entry.lastAccessedAt = now
        storage[key] = entry
        return entry.value
    }

    /// The number of stored entries, including entries not yet checked for expiration.
    public var count: Int {
        storage.count
    }

    private func insert(_ value: Value, for key: Key, now: ContinuousClock.Instant) {
        let expiresAt = policy.ttl.map { now.advanced(by: $0) }
        storage[key] = CacheEntry(value: value, expiresAt: expiresAt, lastAccessedAt: now)
        trimIfNeeded()
    }

    private func trimIfNeeded() {
        guard let countLimit = policy.countLimit, countLimit >= 0 else {
            return
        }

        while storage.count > countLimit {
            guard let key = storage.min(by: { $0.value.lastAccessedAt < $1.value.lastAccessedAt })?.key else {
                return
            }
            storage[key] = nil
        }
    }
}
