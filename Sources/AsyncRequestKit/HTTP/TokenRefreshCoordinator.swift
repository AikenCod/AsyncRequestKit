import Foundation

public actor TokenRefreshCoordinator<Value: Sendable> {
    private var refreshTask: Task<Value, Error>?

    public init() {}

    public func refresh(
        _ operation: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        if let refreshTask {
            return try await refreshTask.value
        }

        let task = Task<Value, Error> {
            try await operation()
        }
        refreshTask = task

        do {
            let value = try await task.value
            refreshTask = nil
            return value
        } catch {
            refreshTask = nil
            throw error
        }
    }
}
