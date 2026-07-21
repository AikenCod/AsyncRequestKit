import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Errors produced while validating an HTTP transport response.
public enum HTTPClientError: Error, Sendable, Equatable {
    /// The transport returned a response that was not an HTTP response.
    case invalidResponse
    /// Status-code validation rejected the response and preserves its body data.
    case unacceptableStatusCode(Int, Data)
}

/// Configuration applied by an ``HTTPClient`` to each request.
public struct HTTPClientConfiguration: Sendable {
    /// A base URL used to resolve relative request paths.
    public var baseURL: URL?
    /// An optional policy for transport-level retry attempts.
    public var retryPolicy: RetryPolicy?
    /// An optional duration after which a request is cancelled.
    public var timeout: Duration?
    /// Whether responses outside the `200..<300` range should throw.
    public var validateStatusCode: Bool
    /// Headers added when a request does not already provide the same field.
    public var defaultHeaders: [String: String]
    /// Ordered hooks that adapt requests and decide whether failures should retry.
    public var interceptors: [any HTTPInterceptor]
    /// The maximum number of interceptor-directed retries per request.
    public var interceptorRetryLimit: Int

    /// Creates a client configuration.
    public init(
        baseURL: URL? = nil,
        retryPolicy: RetryPolicy? = nil,
        timeout: Duration? = nil,
        validateStatusCode: Bool = true,
        defaultHeaders: [String: String] = [:],
        interceptors: [any HTTPInterceptor] = [],
        interceptorRetryLimit: Int = 1
    ) {
        self.baseURL = baseURL
        self.retryPolicy = retryPolicy
        self.timeout = timeout
        self.validateStatusCode = validateStatusCode
        self.defaultHeaders = defaultHeaders
        self.interceptors = interceptors
        self.interceptorRetryLimit = interceptorRetryLimit
    }
}

/// A sendable HTTP client with an injectable asynchronous transport.
public struct HTTPClient: Sendable {
    /// The transport closure used to execute a URL request.
    public typealias Transport = @Sendable (URLRequest) async throws -> (Data, URLResponse)

    let configuration: HTTPClientConfiguration
    let transport: Transport

    /// Creates a client, using `URLSession.shared` when no transport is supplied.
    public init(
        configuration: HTTPClientConfiguration = HTTPClientConfiguration(),
        transport: Transport? = nil
    ) {
        self.configuration = configuration
        self.transport = transport ?? { request in
            try await URLSession.shared.data(for: request, delegate: nil)
        }
    }
}
