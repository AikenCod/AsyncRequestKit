import Foundation

extension HTTPClient {
    public func get<T: Decodable>(
        _ path: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await request(
            path,
            method: "GET",
            parameters: parameters,
            headers: headers,
            encoding: URLEncoding.default,
            decoder: decoder
        )
    }

    public func get<T: Decodable>(
        _ url: URL,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await request(
            url,
            method: "GET",
            parameters: parameters,
            headers: headers,
            encoding: URLEncoding.default,
            decoder: decoder
        )
    }

    public func post<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await request(
            path,
            method: "POST",
            body: body,
            headers: headers,
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
        try await request(
            path,
            method: "POST",
            parameters: parameters,
            headers: headers,
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
        try await request(
            url,
            method: "POST",
            body: body,
            headers: headers,
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
        try await request(
            url,
            method: "POST",
            parameters: parameters,
            headers: headers,
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
        try await request(
            path,
            method: "PUT",
            body: body,
            headers: headers,
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
        try await request(
            path,
            method: "PUT",
            parameters: parameters,
            headers: headers,
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
        try await request(
            url,
            method: "PUT",
            body: body,
            headers: headers,
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
        try await request(
            url,
            method: "PUT",
            parameters: parameters,
            headers: headers,
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
        try await request(
            path,
            method: "PATCH",
            body: body,
            headers: headers,
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
        try await request(
            path,
            method: "PATCH",
            parameters: parameters,
            headers: headers,
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
        try await request(
            url,
            method: "PATCH",
            body: body,
            headers: headers,
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
        try await request(
            url,
            method: "PATCH",
            parameters: parameters,
            headers: headers,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func delete<T: Decodable>(
        _ path: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await request(
            path,
            method: "DELETE",
            parameters: parameters,
            headers: headers,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func delete<T: Decodable>(
        _ url: URL,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await request(
            url,
            method: "DELETE",
            parameters: parameters,
            headers: headers,
            encoding: encoding,
            decoder: decoder
        )
    }

    public func delete(
        _ path: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil
    ) async throws {
        try await request(
            path,
            method: "DELETE",
            parameters: parameters,
            headers: headers,
            encoding: encoding
        )
    }

    public func delete(
        _ url: URL,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil
    ) async throws {
        try await request(
            url,
            method: "DELETE",
            parameters: parameters,
            headers: headers,
            encoding: encoding
        )
    }
}
