import Foundation

public enum HTTPClientError: Error, Sendable, Equatable {
    case invalidResponse
    case unacceptableStatusCode(Int, Data)
}

public struct HTTPClientConfiguration: Sendable {
    public var retryPolicy: RetryPolicy?
    public var timeout: Duration?
    public var validateStatusCode: Bool

    public init(
        retryPolicy: RetryPolicy? = nil,
        timeout: Duration? = nil,
        validateStatusCode: Bool = true
    ) {
        self.retryPolicy = retryPolicy
        self.timeout = timeout
        self.validateStatusCode = validateStatusCode
    }
}

public struct HTTPClient: Sendable {
    public typealias Transport = @Sendable (URLRequest) async throws -> (Data, URLResponse)

    private let configuration: HTTPClientConfiguration
    private let transport: Transport

    public init(
        configuration: HTTPClientConfiguration = HTTPClientConfiguration(),
        transport: Transport? = nil
    ) {
        self.configuration = configuration
        self.transport = transport ?? { request in
            try await URLSession.shared.data(for: request, delegate: nil)
        }
    }

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let work: @Sendable () async throws -> (Data, HTTPURLResponse) = {
            try await self.execute(request)
        }

        if let retryPolicy = configuration.retryPolicy {
            if let timeout = configuration.timeout {
                return try await retryPolicy.run {
                    try await withTimeout(timeout, operation: work)
                }
            }

            return try await retryPolicy.run(operation: work)
        }

        if let timeout = configuration.timeout {
            return try await withTimeout(timeout, operation: work)
        }

        return try await work()
    }

    public func data(for request: URLRequest) async throws -> Data {
        let (data, _) = try await send(request)
        return data
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await data(for: request)
        return try decoder.decode(T.self, from: data)
    }

    public func get<T: Decodable>(
        _ url: URL,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        return try await decode(T.self, from: request, decoder: decoder)
    }

    private func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await transport(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        if configuration.validateStatusCode, !(200...299).contains(httpResponse.statusCode) {
            throw HTTPClientError.unacceptableStatusCode(httpResponse.statusCode, data)
        }

        return (data, httpResponse)
    }
}
