import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension HTTPClient {
    public func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let preparedRequest = preparedRequest(request)
        let work: @Sendable () async throws -> (Data, HTTPURLResponse) = {
            try await self.executeWithInterceptors(preparedRequest)
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

    public func perform(_ request: URLRequest) async throws {
        _ = try await send(request)
    }

    public func perform(
        _ request: URLRequest,
        parameters: Parameters,
        encoding: any ParameterEncoding
    ) async throws {
        _ = try await send(request, parameters: parameters, encoding: encoding)
    }

    public func perform<Body: Encodable>(
        _ request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder()
    ) async throws {
        _ = try await send(request, body: body, encoder: encoder)
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await data(for: request)
        return try decodeValue(T.self, from: data, decoder: decoder)
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        parameters: Parameters,
        encoding: any ParameterEncoding,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await data(for: request, parameters: parameters, encoding: encoding)
        return try decodeValue(T.self, from: data, decoder: decoder)
    }

    public func decode<T: Decodable, Body: Encodable>(
        _ type: T.Type,
        from request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let data = try await data(for: request, body: body, encoder: encoder)
        return try decodeValue(T.self, from: data, decoder: decoder)
    }

    public func response<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        let (data, response) = try await send(request)
        let value = try decodeValue(T.self, from: data, decoder: decoder)
        return HTTPResponse(value: value, data: data, response: response)
    }

    public func response<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        parameters: Parameters,
        encoding: any ParameterEncoding,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        let (data, response) = try await send(request, parameters: parameters, encoding: encoding)
        let value = try decodeValue(T.self, from: data, decoder: decoder)
        return HTTPResponse(value: value, data: data, response: response)
    }

    public func response<T: Decodable, Body: Encodable>(
        _ type: T.Type,
        from request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        let (data, response) = try await send(request, body: body, encoder: encoder)
        let value = try decodeValue(T.self, from: data, decoder: decoder)
        return HTTPResponse(value: value, data: data, response: response)
    }

    func decodeValue<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        decoder: JSONDecoder
    ) throws -> T {
        if data.isEmpty,
           let emptyType = T.self as? any EmptyResponseRepresentable.Type,
           let emptyValue = emptyType.emptyValue() as? T {
            return emptyValue
        }

        return try decoder.decode(T.self, from: data)
    }
}
