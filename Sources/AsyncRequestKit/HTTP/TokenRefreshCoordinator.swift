import Foundation

/// Coalesces concurrent refresh requests so they await a single operation.
public actor TokenRefreshCoordinator<Value: Sendable> {
    private var refreshTask: Task<Value, Error>?

    /// Creates an idle refresh coordinator.
    public init() {}

    /// Starts a refresh or joins the refresh already in progress.
    ///
    /// A completed task, whether successful or failed, is cleared so the next call
    /// can start a new refresh.
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
