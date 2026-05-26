import Foundation

public extension AK {
    static func upload<T: Decodable>(
        _ path: String,
        method: String = "POST",
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.upload(
                path,
                method: method,
                headers: headers,
                decoder: decoder,
                multipart: multipart
            )
        }
    }

    static func upload<T: Decodable>(
        _ url: URL,
        method: String = "POST",
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws -> T {
        try await withSharedClient { client in
            try await client.upload(
                url,
                method: method,
                headers: headers,
                decoder: decoder,
                multipart: multipart
            )
        }
    }

    static func upload(
        _ path: String,
        method: String = "POST",
        headers: [String: String] = [:],
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws {
        try await withSharedClient { client in
            try await client.upload(
                path,
                method: method,
                headers: headers,
                multipart: multipart
            )
        }
    }

    static func upload(
        _ url: URL,
        method: String = "POST",
        headers: [String: String] = [:],
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws {
        try await withSharedClient { client in
            try await client.upload(
                url,
                method: method,
                headers: headers,
                multipart: multipart
            )
        }
    }

    static func uploadResponse<T: Decodable>(
        _ path: String,
        method: String = "POST",
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws -> HTTPResponse<T> {
        try await withSharedClient { client in
            try await client.uploadResponse(
                path,
                method: method,
                headers: headers,
                decoder: decoder,
                multipart: multipart
            )
        }
    }

    static func uploadResponse<T: Decodable>(
        _ url: URL,
        method: String = "POST",
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws -> HTTPResponse<T> {
        try await withSharedClient { client in
            try await client.uploadResponse(
                url,
                method: method,
                headers: headers,
                decoder: decoder,
                multipart: multipart
            )
        }
    }
}
