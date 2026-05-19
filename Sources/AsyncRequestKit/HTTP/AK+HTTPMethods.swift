import Foundation

public extension AK {
    static func get<T: Decodable>(
        _ path: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.get(path, parameters: parameters, headers: headers, decoder: decoder)
        }
    }

    static func get<T: Decodable>(
        _ url: URL,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.get(url, parameters: parameters, headers: headers, decoder: decoder)
        }
    }

    static func post<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.post(path, body: body, headers: headers, encoder: encoder, decoder: decoder)
        }
    }

    static func post<T: Decodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.post(path, parameters: parameters, headers: headers, encoding: encoding, decoder: decoder)
        }
    }

    static func post<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.post(url, body: body, headers: headers, encoder: encoder, decoder: decoder)
        }
    }

    static func post<T: Decodable>(
        _ url: URL,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.post(url, parameters: parameters, headers: headers, encoding: encoding, decoder: decoder)
        }
    }

    static func put<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.put(path, body: body, headers: headers, encoder: encoder, decoder: decoder)
        }
    }

    static func put<T: Decodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.put(path, parameters: parameters, headers: headers, encoding: encoding, decoder: decoder)
        }
    }

    static func put<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.put(url, body: body, headers: headers, encoder: encoder, decoder: decoder)
        }
    }

    static func put<T: Decodable>(
        _ url: URL,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.put(url, parameters: parameters, headers: headers, encoding: encoding, decoder: decoder)
        }
    }

    static func patch<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.patch(path, body: body, headers: headers, encoder: encoder, decoder: decoder)
        }
    }

    static func patch<T: Decodable>(
        _ path: String,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.patch(path, parameters: parameters, headers: headers, encoding: encoding, decoder: decoder)
        }
    }

    static func patch<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.patch(url, body: body, headers: headers, encoder: encoder, decoder: decoder)
        }
    }

    static func patch<T: Decodable>(
        _ url: URL,
        parameters: Parameters,
        headers: [String: String] = [:],
        encoding: any ParameterEncoding = JSONEncoding.default,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.patch(url, parameters: parameters, headers: headers, encoding: encoding, decoder: decoder)
        }
    }

    static func delete<T: Decodable>(
        _ path: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.delete(path, parameters: parameters, headers: headers, encoding: encoding, decoder: decoder)
        }
    }

    static func delete<T: Decodable>(
        _ url: URL,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.delete(url, parameters: parameters, headers: headers, encoding: encoding, decoder: decoder)
        }
    }

    static func delete(
        _ path: String,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil
    ) async throws {
        try await withSharedClient { client in
            try await client.delete(path, parameters: parameters, headers: headers, encoding: encoding)
        }
    }

    static func delete(
        _ url: URL,
        parameters: Parameters? = nil,
        headers: [String: String] = [:],
        encoding: (any ParameterEncoding)? = nil
    ) async throws {
        try await withSharedClient { client in
            try await client.delete(url, parameters: parameters, headers: headers, encoding: encoding)
        }
    }
}
