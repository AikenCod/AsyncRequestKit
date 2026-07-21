import AsyncRequestKit
import Foundation

struct Todo: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

struct CreatePostBody: Encodable {
    let title: String
    let body: String
    let userId: Int
}

struct CreatedPost: Decodable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
}

@main
enum AsyncRequestKitDemo {
    static func main() async {
        await AK.configure(
            HTTPClientConfiguration(
                baseURL: URL(string: "https://jsonplaceholder.typicode.com")!,
                retryPolicy: .fixed(maxAttempts: 2, delay: .milliseconds(200)),
                timeout: .seconds(5),
                defaultHeaders: [
                    "Accept": "application/json"
                ]
            )
        )

        do {
            let client = await AK.shared

            let todo: Todo = try await client.get("/todos/1")
            print("Fetched todo #\(todo.id): \(todo.title) [completed: \(todo.completed)]")

            let created: CreatedPost = try await client.post(
                "/posts",
                body: CreatePostBody(
                    title: "AsyncRequestKit Demo",
                    body: "Posted with AK.shared against JSONPlaceholder.",
                    userId: 1
                )
            )

            print("Created post #\(created.id): \(created.title)")
        } catch {
            let message = Data("Demo failed: \(error)\n".utf8)
            try? FileHandle.standardError.write(contentsOf: message)
            Foundation.exit(1)
        }
    }
}
