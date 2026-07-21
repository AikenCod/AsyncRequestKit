import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum HTTPClientError: Error, Sendable, Equatable {
    case invalidResponse
    case unacceptableStatusCode(Int, Data)
}

public struct HTTPClientConfiguration: Sendable {
    public var baseURL: URL?
    public var retryPolicy: RetryPolicy?
    public var timeout: Duration?
    public var validateStatusCode: Bool
    public var defaultHeaders: [String: String]
    public var interceptors: [any HTTPInterceptor]
    public var interceptorRetryLimit: Int

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

public struct HTTPClient: Sendable {
    public typealias Transport = @Sendable (URLRequest) async throws -> (Data, URLResponse)

    let configuration: HTTPClientConfiguration
    let transport: Transport

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
