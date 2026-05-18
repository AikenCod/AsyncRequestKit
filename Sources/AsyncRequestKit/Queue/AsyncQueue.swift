import Foundation

public enum AsyncJobPriority: Int, Sendable, Comparable {
    case low = 0
    case normal = 1
    case high = 2

    public static func < (lhs: AsyncJobPriority, rhs: AsyncJobPriority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public enum AsyncJobState: Sendable, Equatable {
    case pending
    case running
    case succeeded
    case failed
    case cancelled
}

public final class AsyncJob<Value: Sendable>: Sendable {
    public let id: UUID

    private let task: Task<Value, Error>
    private let stateProvider: @Sendable () async -> AsyncJobState
    private let cancelHandler: @Sendable () async -> Void

    init(
        id: UUID,
        task: Task<Value, Error>,
        stateProvider: @escaping @Sendable () async -> AsyncJobState,
        cancelHandler: @escaping @Sendable () async -> Void
    ) {
        self.id = id
        self.task = task
        self.stateProvider = stateProvider
        self.cancelHandler = cancelHandler
    }

    public var value: Value {
        get async throws {
            try await task.value
        }
    }

    public var state: AsyncJobState {
        get async {
            await stateProvider()
        }
    }

    public func cancel() async {
        await cancelHandler()
    }
}

public actor AsyncQueue {
    private struct QueueEntry: Sendable {
        let id: UUID
        let priority: AsyncJobPriority
        let sequence: UInt64
        let start: @Sendable () -> Void
        let cancel: @Sendable () -> Void
    }

    private let maxConcurrentTasks: Int
    private var isPaused = false
    private var isClosed = false
    private var sequence: UInt64 = 0
    private var pending: [QueueEntry] = []
    private var running: [UUID: QueueEntry] = [:]
    private var states: [UUID: AsyncJobState] = [:]

    public init(maxConcurrentTasks: Int) {
        self.maxConcurrentTasks = max(1, maxConcurrentTasks)
    }

    public func add<Value: Sendable>(
        priority: AsyncJobPriority = .normal,
        operation: @escaping @Sendable () async throws -> Value
    ) -> AsyncJob<Value> {
        let id = UUID()
        let box = AsyncResultBox<Value>()
        let execution = ScheduledExecution(
            queue: self,
            jobID: id,
            resultBox: box,
            operation: operation
        )

        let cancelHandler: @Sendable () -> Void = { execution.cancel() }
        let awaitingTask = Task<Value, Error> { [cancelHandler] in
            try await withTaskCancellationHandler {
                try await box.value()
            } onCancel: {
                cancelHandler()
            }
        }

        let entry = QueueEntry(
            id: id,
            priority: priority,
            sequence: sequence,
            start: { execution.start() },
            cancel: { execution.cancel() }
        )

        sequence += 1
        states[id] = .pending

        if isClosed {
            states[id] = .failed
            execution.failImmediately(with: AsyncRequestKitError.queueClosed)
        } else {
            pending.append(entry)
            scheduleIfNeeded()
        }

        return AsyncJob(
            id: id,
            task: awaitingTask,
            stateProvider: { [weak self] in
                guard let self else { return .cancelled }
                return await self.state(for: id)
            },
            cancelHandler: { [weak self] in
                await self?.cancel(id: id)
            }
        )
    }

    public func pause() {
        isPaused = true
    }

    public func resume() {
        isPaused = false
        scheduleIfNeeded()
    }

    public func cancelAll() {
        for entry in pending {
            states[entry.id] = .cancelled
            entry.cancel()
        }
        pending.removeAll()

        for (id, entry) in running {
            states[id] = .cancelled
            entry.cancel()
        }
    }

    public func close() {
        isClosed = true
        cancelAll()
    }

    public func state(for id: UUID) -> AsyncJobState {
        states[id] ?? .cancelled
    }

    fileprivate func markFinished(id: UUID, state: AsyncJobState) {
        running[id] = nil
        if states[id] != .cancelled {
            states[id] = state
        }
        scheduleIfNeeded()
    }

    private func cancel(id: UUID) {
        if let index = pending.firstIndex(where: { $0.id == id }) {
            let entry = pending.remove(at: index)
            states[id] = .cancelled
            entry.cancel()
            return
        }

        guard let entry = running[id] else {
            return
        }

        states[id] = .cancelled
        entry.cancel()
    }

    private func scheduleIfNeeded() {
        guard !isPaused else {
            return
        }

        while running.count < maxConcurrentTasks, let next = nextPendingEntry() {
            running[next.id] = next
            states[next.id] = .running
            next.start()
        }
    }

    private func nextPendingEntry() -> QueueEntry? {
        guard let index = pending.indices.max(by: { lhs, rhs in
            let left = pending[lhs]
            let right = pending[rhs]

            if left.priority == right.priority {
                return left.sequence > right.sequence
            }
            return left.priority < right.priority
        }) else {
            return nil
        }

        return pending.remove(at: index)
    }
}

private actor AsyncResultBox<Value: Sendable> {
    private enum State {
        case pending([CheckedContinuation<Result<Value, Error>, Never>])
        case completed(Result<Value, Error>)
    }

    private var state: State = .pending([])

    func value() async throws -> Value {
        let result = await withCheckedContinuation { continuation in
            switch state {
            case .pending(var continuations):
                continuations.append(continuation)
                state = .pending(continuations)
            case .completed(let result):
                continuation.resume(returning: result)
            }
        }

        return try result.get()
    }

    func succeed(_ value: Value) {
        complete(.success(value))
    }

    func fail(_ error: Error) {
        complete(.failure(error))
    }

    private func complete(_ result: Result<Value, Error>) {
        switch state {
        case .completed:
            return
        case .pending(let continuations):
            state = .completed(result)
            continuations.forEach { $0.resume(returning: result) }
        }
    }
}

private final class ScheduledExecution<Value: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private weak var queue: AsyncQueue?
    private let jobID: UUID
    private let resultBox: AsyncResultBox<Value>
    private let operation: @Sendable () async throws -> Value
    private var task: Task<Void, Never>?
    private var finished = false

    init(
        queue: AsyncQueue,
        jobID: UUID,
        resultBox: AsyncResultBox<Value>,
        operation: @escaping @Sendable () async throws -> Value
    ) {
        self.queue = queue
        self.jobID = jobID
        self.resultBox = resultBox
        self.operation = operation
    }

    func start() {
        let shouldStart = lock.withLock { () -> Bool in
            guard !finished, self.task == nil else { return false }
            return true
        }

        guard shouldStart else {
            return
        }

        let startedTask = Task { [operation, resultBox, weak queue] in
            do {
                let value = try await operation()
                await resultBox.succeed(value)
                await queue?.markFinished(id: self.jobID, state: .succeeded)
                self.markCompleted()
            } catch is CancellationError {
                await resultBox.fail(CancellationError())
                await queue?.markFinished(id: self.jobID, state: .cancelled)
                self.markCompleted()
            } catch {
                await resultBox.fail(error)
                await queue?.markFinished(id: self.jobID, state: .failed)
                self.markCompleted()
            }
        }

        lock.withLock {
            if finished {
                startedTask.cancel()
            } else {
                self.task = startedTask
            }
        }
    }

    func cancel() {
        let runningTask = lock.withLock { () -> Task<Void, Never>? in
            if finished {
                return nil
            }

            finished = true
            let runningTask = task
            task = nil
            return runningTask
        }

        Task {
            await resultBox.fail(CancellationError())
        }

        if let runningTask {
            runningTask.cancel()
        }
    }

    func failImmediately(with error: Error) {
        let shouldFail = lock.withLock { () -> Bool in
            guard !finished else { return false }
            finished = true
            return true
        }

        guard shouldFail else {
            return
        }

        Task {
            await resultBox.fail(error)
        }
    }

    private func markCompleted() {
        lock.withLock {
            finished = true
            task = nil
        }
    }
}

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}
