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

    public static var shared: HTTPClient {
        get async {
            await store.currentClient()
        }
    }

    public static func configure(_ configuration: HTTPClientConfiguration) async {
        await store.configure(configuration)
    }

    public static func use(_ client: HTTPClient) async {
        await store.use(client)
    }

    public static func reset() async {
        await store.reset()
    }
}
