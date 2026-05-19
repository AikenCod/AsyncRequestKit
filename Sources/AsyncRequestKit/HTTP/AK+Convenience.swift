import Foundation

public extension AK {
    static func request<T: Decodable>(
        _ path: String,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.request(
                path,
                method: method,
                parameters: parameters,
                headers: headers,
                encoding: encoding,
                decoder: decoder
            )
        }
    }

    static func request<T: Decodable>(
        _ url: URL,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.request(
                url,
                method: method,
                parameters: parameters,
                headers: headers,
                encoding: encoding,
                decoder: decoder
            )
        }
    }

    static func request<Body: Encodable, T: Decodable>(
        _ path: String,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.request(
                path,
                method: method,
                body: body,
                headers: headers,
                encoder: encoder,
                decoder: decoder
            )
        }
    }

    static func request<Body: Encodable, T: Decodable>(
        _ url: URL,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.request(
                url,
                method: method,
                body: body,
                headers: headers,
                encoder: encoder,
                decoder: decoder
            )
        }
    }

    static func request(
        _ path: String,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil
    ) async throws {
        try await withSharedClient { client in
            try await client.request(
                path,
                method: method,
                parameters: parameters,
                headers: headers,
                encoding: encoding
            )
        }
    }

    static func request(
        _ url: URL,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil
    ) async throws {
        try await withSharedClient { client in
            try await client.request(
                url,
                method: method,
                parameters: parameters,
                headers: headers,
                encoding: encoding
            )
        }
    }

    static func request<Body: Encodable>(
        _ path: String,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) async throws {
        try await withSharedClient { client in
            try await client.request(
                path,
                method: method,
                body: body,
                headers: headers,
                encoder: encoder
            )
        }
    }

    static func request<Body: Encodable>(
        _ url: URL,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder()
    ) async throws {
        try await withSharedClient { client in
            try await client.request(
                url,
                method: method,
                body: body,
                headers: headers,
                encoder: encoder
            )
        }
    }

    static func requestResponse<T: Decodable>(
        _ path: String,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        try await withSharedClient { client in
            try await client.requestResponse(
                path,
                method: method,
                parameters: parameters,
                headers: headers,
                encoding: encoding,
                decoder: decoder
            )
        }
    }

    static func requestResponse<T: Decodable>(
        _ url: URL,
        method: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        try await withSharedClient { client in
            try await client.requestResponse(
                url,
                method: method,
                parameters: parameters,
                headers: headers,
                encoding: encoding,
                decoder: decoder
            )
        }
    }

    static func requestResponse<Body: Encodable, T: Decodable>(
        _ path: String,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        try await withSharedClient { client in
            try await client.requestResponse(
                path,
                method: method,
                body: body,
                headers: headers,
                encoder: encoder,
                decoder: decoder
            )
        }
    }

    static func requestResponse<Body: Encodable, T: Decodable>(
        _ url: URL,
        method: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> HTTPResponse<T> {
        try await withSharedClient { client in
            try await client.requestResponse(
                url,
                method: method,
                body: body,
                headers: headers,
                encoder: encoder,
                decoder: decoder
            )
        }
    }
}
