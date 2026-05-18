public enum AsyncRequestKitError: Error, Sendable, Equatable {
    case invalidConcurrencyLimit
    case queueClosed
}
