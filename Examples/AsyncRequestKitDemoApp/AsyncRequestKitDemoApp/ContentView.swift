import AsyncRequestKit
import Combine
import SwiftUI

private struct Todo: Decodable {
    let id: Int
    let title: String
    let completed: Bool
}

private struct CreatePostBody: Encodable {
    let title: String
    let body: String
    let userId: Int
}

private struct CreatedPost: Decodable {
    let id: Int
    let title: String
}

private actor DemoBootstrapper {
    private var isConfigured = false

    func configureIfNeeded() async {
        guard !isConfigured else {
            return
        }

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

        isConfigured = true
    }
}

private enum DemoAPI {
    static let bootstrapper = DemoBootstrapper()
}

@MainActor
private final class DemoViewModel: ObservableObject {
    @Published var todoSummary = "Not loaded"
    @Published var postSummary = "Not created"
    @Published var status = "Ready"
    @Published var isLoadingTodo = false
    @Published var isCreatingPost = false

    func loadTodo() async {
        guard !isLoadingTodo else {
            return
        }

        isLoadingTodo = true
        status = "Loading todo..."
        defer { isLoadingTodo = false }

        do {
            await DemoAPI.bootstrapper.configureIfNeeded()
            let client = await AK.shared
            let todo: Todo = try await client.get("/todos/1")
            todoSummary = "#\(todo.id) \(todo.title)"
            status = todo.completed ? "Todo fetched (completed)." : "Todo fetched."
        } catch {
            status = "Load failed: \(error.localizedDescription)"
        }
    }

    func createPost() async {
        guard !isCreatingPost else {
            return
        }

        isCreatingPost = true
        status = "Creating post..."
        defer { isCreatingPost = false }

        do {
            await DemoAPI.bootstrapper.configureIfNeeded()
            let client = await AK.shared
            let post: CreatedPost = try await client.post(
                "/posts",
                body: CreatePostBody(
                    title: "AsyncRequestKit Demo",
                    body: "Created from the Xcode demo app.",
                    userId: 1
                )
            )
            postSummary = "#\(post.id) \(post.title)"
            status = "Post created."
        } catch {
            status = "Create failed: \(error.localizedDescription)"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = DemoViewModel()

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("AsyncRequestKit")
                        .font(.largeTitle.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    summaryCard
                    todoCard
                    postCard
                }
                .padding(20)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .task {
            await viewModel.loadTodo()
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "bolt.horizontal.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(.blue, .cyan)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Shared Client Demo")
                        .font(.title2.weight(.semibold))

                    Text("Configured once with AK, then reused for GET and POST requests against JSONPlaceholder.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 10) {
                methodPill(title: "GET", endpoint: "/todos/1", tint: .blue)
                methodPill(title: "POST", endpoint: "/posts", tint: .green)
            }

            HStack(spacing: 10) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(.secondary)
                Text(viewModel.status)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var todoCard: some View {
        requestCard(
            title: "Fetch Todo",
            subtitle: "Reads one item from the public API with the shared client.",
            method: "GET",
            endpoint: "/todos/1",
            response: viewModel.todoSummary,
            buttonTitle: viewModel.isLoadingTodo ? "Fetching..." : "Fetch Todo",
            buttonImage: "arrow.down.circle.fill",
            tint: .blue,
            isDisabled: viewModel.isLoadingTodo
        ) {
            Task {
                await viewModel.loadTodo()
            }
        }
    }

    private var postCard: some View {
        requestCard(
            title: "Create Post",
            subtitle: "Sends a JSON body and decodes the created payload.",
            method: "POST",
            endpoint: "/posts",
            response: viewModel.postSummary,
            buttonTitle: viewModel.isCreatingPost ? "Creating..." : "Create Post",
            buttonImage: "square.and.arrow.up.fill",
            tint: .green,
            isDisabled: viewModel.isCreatingPost
        ) {
            Task {
                await viewModel.createPost()
            }
        }
    }

    private func requestCard(
        title: String,
        subtitle: String,
        method: String,
        endpoint: String,
        response: String,
        buttonTitle: String,
        buttonImage: String,
        tint: Color,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            methodPill(title: method, endpoint: endpoint, tint: tint)

            VStack(alignment: .leading, spacing: 8) {
                Text("Response")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(response)
                    .font(.body.weight(.medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Button(action: action) {
                Label(buttonTitle, systemImage: buttonImage)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(tint)
            .controlSize(.large)
            .disabled(isDisabled)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func methodPill(title: String, endpoint: String, tint: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
            Text(endpoint)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(tint.opacity(0.08), in: Capsule())
    }
}

#Preview {
    ContentView()
}
