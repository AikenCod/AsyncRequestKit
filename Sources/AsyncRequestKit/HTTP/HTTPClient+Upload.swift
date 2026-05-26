import Foundation

extension HTTPClient {
    public func upload<T: Decodable>(
        _ path: String,
        method: String = "POST",
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws -> T {
        let request = try multipartRequest(
            try request(for: path, method: method, headers: headers),
            multipart: multipart
        )
        return try await decode(T.self, from: request, decoder: decoder)
    }

    public func upload<T: Decodable>(
        _ url: URL,
        method: String = "POST",
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws -> T {
        let request = try multipartRequest(
            request(url: url, method: method, headers: headers),
            multipart: multipart
        )
        return try await decode(T.self, from: request, decoder: decoder)
    }

    public func upload(
        _ path: String,
        method: String = "POST",
        headers: [String: String] = [:],
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws {
        let request = try multipartRequest(
            try request(for: path, method: method, headers: headers),
            multipart: multipart
        )
        try await perform(request)
    }

    public func upload(
        _ url: URL,
        method: String = "POST",
        headers: [String: String] = [:],
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws {
        let request = try multipartRequest(
            request(url: url, method: method, headers: headers),
            multipart: multipart
        )
        try await perform(request)
    }

    public func uploadResponse<T: Decodable>(
        _ path: String,
        method: String = "POST",
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws -> HTTPResponse<T> {
        let request = try multipartRequest(
            try request(for: path, method: method, headers: headers),
            multipart: multipart
        )
        return try await response(T.self, from: request, decoder: decoder)
    }

    public func uploadResponse<T: Decodable>(
        _ url: URL,
        method: String = "POST",
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder(),
        multipart: (inout MultipartFormData) throws -> Void
    ) async throws -> HTTPResponse<T> {
        let request = try multipartRequest(
            request(url: url, method: method, headers: headers),
            multipart: multipart
        )
        return try await response(T.self, from: request, decoder: decoder)
    }

    private func multipartRequest(
        _ request: URLRequest,
        multipart: (inout MultipartFormData) throws -> Void
    ) throws -> URLRequest {
        var form = MultipartFormData()
        try multipart(&form)

        var request = request
        let boundary = "AsyncRequestKit-\(UUID().uuidString)"
        request.httpBody = form.encodedData(boundary: boundary)
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        return request
    }
}
