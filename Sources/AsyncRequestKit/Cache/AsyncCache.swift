public struct CachePolicy: Sendable, Equatable {
    public let ttl: Duration?
    public let countLimit: Int?

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

public actor AsyncCache<Key: Hashable & Sendable, Value: Sendable> {
    private let policy: CachePolicy
    private let clock = ContinuousClock()
    private var storage: [Key: CacheEntry<Value>] = [:]
    private var inFlightTasks: [Key: Task<Value, Error>] = [:]

    public init(policy: CachePolicy = CachePolicy()) {
        self.policy = policy
    }

    public init(ttl: Duration? = nil, countLimit: Int? = nil) {
        self.policy = CachePolicy(ttl: ttl, countLimit: countLimit)
    }

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

    public func setValue(_ value: Value, for key: Key) {
        insert(value, for: key, now: clock.now)
    }

    public func removeValue(for key: Key) {
        storage[key] = nil
        inFlightTasks[key]?.cancel()
        inFlightTasks[key] = nil
    }

    public func removeAll() {
        storage.removeAll()
        for task in inFlightTasks.values {
            task.cancel()
        }
        inFlightTasks.removeAll()
    }

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
