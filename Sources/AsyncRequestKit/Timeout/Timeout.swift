import Foundation

/// The error thrown when an operation does not finish within its allowed duration.
public struct TimeoutError: Error, Sendable, Equatable {}

private actor TimeoutCoordinator<T: Sendable> {
    private enum State {
        case pending(CheckedContinuation<T, Error>?)
        case resolved(Result<T, Error>)
    }

    private var state: State = .pending(nil)

    func install(_ continuation: CheckedContinuation<T, Error>) {
        switch state {
        case .pending:
            state = .pending(continuation)
        case .resolved(let result):
            continuation.resume(with: result)
        }
    }

    func succeed(_ value: T) {
        complete(.success(value))
    }

    func fail(_ error: Error) {
        complete(.failure(error))
    }

    private func complete(_ result: Result<T, Error>) {
        switch state {
        case .pending(let continuation):
            state = .resolved(result)
            continuation?.resume(with: result)
        case .resolved:
            return
        }
    }
}

private final class TimeoutTaskBox: @unchecked Sendable {
    private let lock = NSLock()
    private var task: Task<Void, Never>?

    func store(_ task: Task<Void, Never>) {
        lock.lock()
        defer { lock.unlock() }
        self.task = task
    }

    func cancel() {
        lock.lock()
        let task = self.task
        lock.unlock()
        task?.cancel()
    }
}

/// Runs an asynchronous operation with a deadline relative to the current time.
///
/// When the deadline expires, the operation task is cancelled and ``TimeoutError``
/// is thrown. Cancelling the caller cancels both the operation and timeout tasks.
public func withTimeout<T: Sendable>(
    _ duration: Duration,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    let coordinator = TimeoutCoordinator<T>()
    let timeoutTaskBox = TimeoutTaskBox()
    let operationTask = Task {
        do {
            let value = try await operation()
            await coordinator.succeed(value)
        } catch {
            await coordinator.fail(error)
        }
        timeoutTaskBox.cancel()
    }

    let timeoutTask = Task {
        do {
            try await Task.sleep(for: duration)
            operationTask.cancel()
            await coordinator.fail(TimeoutError())
        } catch is CancellationError {
        } catch {
            await coordinator.fail(error)
        }
    }
    timeoutTaskBox.store(timeoutTask)

    return try await withTaskCancellationHandler {
        try await withCheckedThrowingContinuation { continuation in
            Task {
                await coordinator.install(continuation)
            }
        }
    } onCancel: {
        operationTask.cancel()
        timeoutTask.cancel()
        Task {
            await coordinator.fail(CancellationError())
        }
    }
}
