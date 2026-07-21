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

/// A process-wide facade for a shared ``HTTPClient``.
///
/// Prefer a directly owned client when dependencies or configuration should be
/// isolated. Access to the shared value is actor coordinated.
public enum AK {
    private static let store = AKSharedClientStore()

    /// The currently configured shared client.
    public static var shared: HTTPClient {
        get async {
            await store.currentClient()
        }
    }

    /// Replaces the shared client with one created from a configuration.
    public static func configure(_ configuration: HTTPClientConfiguration) async {
        await store.configure(configuration)
    }

    /// Installs an existing client, including its custom transport.
    public static func use(_ client: HTTPClient) async {
        await store.use(client)
    }

    /// Restores the default shared client.
    public static func reset() async {
        await store.reset()
    }

    static func withSharedClient<T>(
        _ operation: (HTTPClient) async throws -> T
    ) async rethrows -> T {
        let client = await store.currentClient()
        return try await operation(client)
    }
}
