import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// An interceptor's decision after observing a failed request.
public enum HTTPRetryDecision: Sendable, Equatable {
    /// Return the original failure to the caller.
    case doNotRetry
    /// Adapt and execute the request again, subject to the client's retry limit.
    case retry
}

/// A request adaptation and failure-recovery hook for ``HTTPClient``.
public protocol HTTPInterceptor: Sendable {
    /// Returns the request to execute, optionally modifying or rejecting it.
    func adapt(_ request: URLRequest) async throws -> URLRequest

    /// Decides whether a failed request should be executed again.
    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> HTTPRetryDecision
}

public extension HTTPInterceptor {
    /// The default implementation returns the request unchanged.
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        request
    }

    /// The default implementation declines a retry.
    func retry(
        _ request: URLRequest,
        dueTo error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> HTTPRetryDecision {
        .doNotRetry
    }
}
