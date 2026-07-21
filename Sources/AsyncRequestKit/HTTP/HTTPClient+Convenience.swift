import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPClient {
    public func request<T: Decodable>(
        _ path: String,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let urlRequest = try request(for: path, method: method, headers: headers)
        return try await request(
            urlRequest,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func request<T: Decodable>(
        _ url: URL,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let urlRequest = request(url: url, method: method, headers: headers)
        return try await request(
            urlRequest,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func request<Body: Encodable, T: Decodable>(
        _ path: String,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = try request(for: path, method: method, headers: headers)
        return try await decode(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func request<Body: Encodable, T: Decodable>(
        _ url: URL,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let request = request(url: url, method: method, headers: headers)
        return try await decode(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func request(
        _ path: String,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil
    ) async throws {
        let request = try request(for: path, method: method, headers: headers)
        try await perform(
            request,
            parameters: parameters,
            encoding: encoding
        )
    }

    public func request(
        _ url: URL,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil
    ) async throws {
        let request = request(url: url, method: method, headers: headers)
        try await perform(
            request,
            parameters: parameters,
            encoding: encoding
        )
    }

    public func request<Body: Encodable>(
        _ path: String,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) async throws {
        let request = try request(for: path, method: method, headers: headers)
        try await perform(request, body: body, encoder: encoder)
    }

    public func request<Body: Encodable>(
        _ url: URL,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) async throws {
        let request = request(url: url, method: method, headers: headers)
        try await perform(request, body: body, encoder: encoder)
    }

    public func requestResponse<T: Decodable>(
        _ path: String,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        let request = try request(for: path, method: method, headers: headers)
        return try await requestResponse(
            request,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func requestResponse<T: Decodable>(
        _ url: URL,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        let request = request(url: url, method: method, headers: headers)
        return try await requestResponse(
            request,
            parameters: parameters,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func requestResponse<Body: Encodable, T: Decodable>(
        _ path: String,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        let request = try request(for: path, method: method, headers: headers)
        return try await response(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public func requestResponse<Body: Encodable, T: Decodable>(
        _ url: URL,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        let request = request(url: url, method: method, headers: headers)
        return try await response(
            T.self,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    func request<T: Decodable>(
        _ request: URLRequest,
        parameters: Parameters?,
        encoding: (any ParameterEncoding)?,
        decoder: JSONDecoder
    ) async throws -> T {
        if let parameters {
            return try await decode(
                T.self,
                from: request,
                parameters: parameters,
                encoding: encoding ?? defaultParameterEncoding(for: request),
                decoder: decoder
            )
        }

        return try await decode(T.self, from: request, decoder: decoder)
    }

    func requestResponse<T: Decodable>(
        _ request: URLRequest,
        parameters: Parameters?,
        encoding: (any ParameterEncoding)?,
        decoder: JSONDecoder
    ) async throws -> HTTPResponse<T> {
        if let parameters {
            return try await response(
                T.self,
                from: request,
                parameters: parameters,
                encoding: encoding ?? defaultParameterEncoding(for: request),
                decoder: decoder
            )
        }

        return try await response(T.self, from: request, decoder: decoder)
    }

    func perform(
        _ request: URLRequest,
        parameters: Parameters?,
        encoding: (any ParameterEncoding)?
    ) async throws {
        if let parameters {
            try await perform(
                request,
                parameters: parameters,
                encoding: encoding ?? defaultParameterEncoding(for: request)
            )
            return
        }

        try await perform(request)
    }

    func request(
        url: URL,
        method: String,
        headers: [String: String]
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)
        return request
    }

    func defaultParameterEncoding(for request: URLRequest) -> any ParameterEncoding {
        let method = request.httpMethod?.uppercased() ?? "GET"
        switch method {
        case "GET", "HEAD", "DELETE":
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}
