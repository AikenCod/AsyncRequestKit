/// Errors shared by AsyncRequestKit's concurrency utilities.
public enum AsyncRequestKitError: Error, Sendable, Equatable {
    /// A concurrency limit was zero or negative.
    case invalidConcurrencyLimit
    /// Work was submitted after an asynchronous queue was closed.
    case queueClosed
}
