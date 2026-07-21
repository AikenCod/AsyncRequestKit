/// Transforms items concurrently while limiting the number of running operations.
///
/// Results preserve the input order. A nonpositive limit throws
/// ``AsyncRequestKitError/invalidConcurrencyLimit``.
public func withLimitedConcurrency<Input: Sendable, Output: Sendable>(
    maxConcurrentTasks limit: Int,
    items: [Input],
    operation: @escaping @Sendable (Input) async throws -> Output
) async throws -> [Output] {
    guard limit > 0 else {
        throw AsyncRequestKitError.invalidConcurrencyLimit
    }

    guard !items.isEmpty else {
        return []
    }

    return try await withThrowingTaskGroup(of: (Int, Output).self) { group in
        var iterator = items.enumerated().makeIterator()
        var pendingResults = Array<Output?>(repeating: nil, count: items.count)
        var runningCount = 0

        func startNextTask() {
            guard let (index, item) = iterator.next() else {
                return
            }

            runningCount += 1
            group.addTask {
                (index, try await operation(item))
            }
        }

        for _ in 0..<min(limit, items.count) {
            startNextTask()
        }

        while runningCount > 0 {
            let (index, output) = try await group.next()!
            runningCount -= 1
            pendingResults[index] = output
            startNextTask()
        }

        return pendingResults.map { $0! }
    }
}
