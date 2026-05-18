import Foundation

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

    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let work: @Sendable () async throws -> (Data, HTTPURLResponse) = {
            try await self.executeWithInterceptors(request)
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

    public func send(
        _ request: URLRequest,
        parameters: Parameters,
        encoding: any ParameterEncoding
    ) async throws -> (Data, HTTPURLResponse) {
        try await send(parameterRequest(request, parameters: parameters, encoding: encoding))
    }

    public func send<Body: Encodable>(
        _ request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder()
    ) async throws -> (Data, HTTPURLResponse) {
        try await send(jsonRequest(request, body: body, encoder: encoder))
    }

    public func data(
        for request: URLRequest,
        parameters: Parameters,
        encoding: any ParameterEncoding
    ) async throws -> Data {
        let (data, _) = try await send(request, parameters: parameters, encoding: encoding)
        return data
    }

    public func data<Body: Encodable>(
        for request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder()
    ) async throws -> Data {
        let (data, _) = try await send(request, body: body, encoder: encoder)
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

    public func decode<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        parameters: Parameters,
        encoding: any ParameterEncoding,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await data(for: request, parameters: parameters, encoding: encoding)
        return try decoder.decode(T.self, from: data)
    }

    public func decode<T: Decodable, Body: Encodable>(
        _ type: T.Type,
        from request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await data(for: request, body: body, encoder: encoder)
        return try decoder.decode(T.self, from: data)
    }

    public func get<T: Decodable>(
        _ path: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = try request(for: path, method: "GET", headers: headers)

        if let parameters {
            return try await decode(
                T.self,
                from: request,
                parameters: parameters,
                encoding: URLEncoding.default,
                decoder: decoder
            )
        }

        return try await decode(T.self, from: request, decoder: decoder)
    }

    public func get<T: Decodable>(
        _ url: URL,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)

        if let parameters {
            return try await decode(
                T.self,
                from: request,
                parameters: parameters,
                encoding: URLEncoding.default,
                decoder: decoder
            )
        }

        return try await decode(T.self, from: request, decoder: decoder)
    }

    public func post<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = try request(for: path, method: "POST", headers: headers)
        return try await decode(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func post<T: Decodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = try request(for: path, method: "POST", headers: headers)
        return try await decode(
            T.self,
            from: request,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func post<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)
        return try await decode(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func post<T: Decodable>(
        _ url: URL,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)
        return try await decode(
            T.self,
            from: request,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func put<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = try request(for: path, method: "PUT", headers: headers)
        return try await decode(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func put<T: Decodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = try request(for: path, method: "PUT", headers: headers)
        return try await decode(
            T.self,
            from: request,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func put<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)
        return try await decode(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func put<T: Decodable>(
        _ url: URL,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)
        return try await decode(
            T.self,
            from: request,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func patch<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = try request(for: path, method: "PATCH", headers: headers)
        return try await decode(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func patch<T: Decodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = try request(for: path, method: "PATCH", headers: headers)
        return try await decode(
            T.self,
            from: request,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func patch<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)
        return try await decode(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func patch<T: Decodable>(
        _ url: URL,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)
        return try await decode(
            T.self,
            from: request,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }
}
