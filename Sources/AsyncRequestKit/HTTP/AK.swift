import Foundation

private actor AKSharedClientStore {
    private var client = HTTPClient()

    func configure(_ configuration: HTTPClientConfiguration) {
        client = HTTPClient(configuration: configuration)
    }

    func use(_ httpClient: HTTPClient) {
        client = httpClient
    }

    func reset() {
        client = HTTPClient()
    }

    func currentClient() -> HTTPClient {
        client
    }
}

public enum AK {
    private static let store = AKSharedClientStore()

    public static func configure(_ configuration: HTTPClientConfiguration) async {
        await store.configure(configuration)
    }

    public static func use(_ client: HTTPClient) async {
        await store.use(client)
    }

    public static func reset() async {
        await store.reset()
    }

    public static func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let client = await store.currentClient()
        return try await client.send(request)
    }

    public static func data(for request: URLRequest) async throws -> Data {
        let client = await store.currentClient()
        return try await client.data(for: request)
    }

    public static func send<Body: Encodable>(
        _ request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder()
    ) async throws -> (Data, HTTPURLResponse) {
        let client = await store.currentClient()
        return try await client.send(request, body: body, encoder: encoder)
    }

    public static func data<Body: Encodable>(
        for request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder()
    ) async throws -> Data {
        let client = await store.currentClient()
        return try await client.data(for: request, body: body, encoder: encoder)
    }

    public static func decode<T: Decodable>(
        _ type: T.Type,
        from request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.decode(type, from: request, decoder: decoder)
    }

    public static func decode<T: Decodable, Body: Encodable>(
        _ type: T.Type,
        from request: URLRequest,
        body: Body,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.decode(
            type,
            from: request,
            body: body,
            encoder: encoder,
            decoder: decoder
        )
    }

    public static func get<T: Decodable>(
        _ path: String,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.get(path, headers: headers, decoder: decoder)
    }

    public static func get<T: Decodable>(
        _ url: URL,
        headers: [String: String] = [:],
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.get(url, headers: headers, decoder: decoder)
    }

    public static func post<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.post(
            path,
            body: body,
            headers: headers,
            encoder: encoder,
            decoder: decoder
        )
    }

    public static func post<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.post(
            url,
            body: body,
            headers: headers,
            encoder: encoder,
            decoder: decoder
        )
    }

    public static func put<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.put(
            path,
            body: body,
            headers: headers,
            encoder: encoder,
            decoder: decoder
        )
    }

    public static func put<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.put(
            url,
            body: body,
            headers: headers,
            encoder: encoder,
            decoder: decoder
        )
    }

    public static func patch<T: Decodable, Body: Encodable>(
        _ path: String,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.patch(
            path,
            body: body,
            headers: headers,
            encoder: encoder,
            decoder: decoder
        )
    }

    public static func patch<T: Decodable, Body: Encodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:],
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let client = await store.currentClient()
        return try await client.patch(
            url,
            body: body,
            headers: headers,
            encoder: encoder,
            decoder: decoder
        )
    }
}
