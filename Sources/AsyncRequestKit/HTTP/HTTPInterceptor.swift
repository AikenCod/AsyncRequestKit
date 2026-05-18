import Foundation

public enum HTTPRetryDecision: Sendable, Equatable {
    case doNotRetry
    case retry
}

public protocol HTTPInterceptor: Sendable {
    func adapt(_ request: URLRequest) async throws -> URLRequest

    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> HTTPRetryDecision
}

public extension HTTPInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        request
    }

    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> HTTPRetryDecision {
        .doNotRetry
    }
}
