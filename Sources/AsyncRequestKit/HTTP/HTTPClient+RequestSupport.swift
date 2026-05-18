import Foundation

extension HTTPClient {
    func executeWithInterceptors(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let originalRequest = request
        var remainingRetries = max(0, configuration.interceptorRetryLimit)

        while true {
            let adaptedRequest = try await adapt(originalRequest)

            do {
                let (data, response) = try await execute(adaptedRequest)

                if configuration.validateStatusCode, !(200...299).contains(response.statusCode) {
                    let error = HTTPClientError.unacceptableStatusCode(response.statusCode, data)
                    let shouldRetry = try await retryDecision(
                        for: adaptedRequest,
                        error: error,
                        response: response,
                        data: data
                    )

                    if shouldRetry, remainingRetries > 0 {
                        remainingRetries -= 1
                        continue
                    }

                    throw error
                }

                return (data, response)
            } catch {
                if let clientError = error as? HTTPClientError,
                   case .unacceptableStatusCode = clientError {
                    throw error
                }

                let shouldRetry = try await retryDecision(
                    for: adaptedRequest,
                    error: error,
                    response: nil,
                    data: nil
                )

                if shouldRetry, remainingRetries > 0 {
                    remainingRetries -= 1
                    continue
                }

                throw error
            }
        }
    }

    func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await transport(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        return (data, httpResponse)
    }

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adaptedRequest = request

        for interceptor in configuration.interceptors {
            adaptedRequest = try await interceptor.adapt(adaptedRequest)
        }

        return adaptedRequest
    }

    func retryDecision(
        for request: URLRequest,
        error: Error,
        response: HTTPURLResponse?,
        data: Data?
    ) async throws -> Bool {
        for interceptor in configuration.interceptors {
            let decision = try await interceptor.retry(
                request,
                dueTo: error,
                response: response,
                data: data
            )

            if decision == .retry {
                return true
            }
        }

        return false
    }

    func jsonRequest<Body: Encodable>(
        _ request: URLRequest,
        body: Body,
        encoder: JSONEncoder
    ) throws -> URLRequest {
        var request = request
        try request.setJSONBody(body, encoder: encoder)
        return request
    }

    func request(
        for path: String,
        method: String,
        headers: [String: String]
    ) throws -> URLRequest {
        var request = URLRequest(url: try resolveURL(for: path))
        request.httpMethod = method
        request.applyHeaders(configuration.defaultHeaders, preservingExistingValues: true)
        request.applyHeaders(headers)
        return request
    }

    func resolveURL(for path: String) throws -> URL {
        if let url = URL(string: path), url.scheme != nil {
            return url
        }

        guard let baseURL = configuration.baseURL else {
            throw URLError(.badURL)
        }

        if path.isEmpty {
            return baseURL
        }

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        let normalizedBasePath = components?.percentEncodedPath ?? ""
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        let basePrefix: String

        if normalizedBasePath.isEmpty || normalizedBasePath == "/" {
            basePrefix = "/"
        } else if normalizedBasePath.hasSuffix("/") {
            basePrefix = normalizedBasePath
        } else {
            basePrefix = normalizedBasePath + "/"
        }

        components?.percentEncodedPath = basePrefix + normalizedPath

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        return url
    }
}

extension URLRequest {
    mutating func setJSONBody<Body: Encodable>(
        _ body: Body,
        encoder: JSONEncoder
    ) throws {
        httpBody = try encoder.encode(body)

        if value(forHTTPHeaderField: "Content-Type") == nil {
            setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if value(forHTTPHeaderField: "Accept") == nil {
            setValue("application/json", forHTTPHeaderField: "Accept")
        }
    }

    mutating func applyHeaders(
        _ headers: [String: String],
        preservingExistingValues: Bool = false
    ) {
        for (field, headerValue) in headers {
            if preservingExistingValues, value(forHTTPHeaderField: field) != nil {
                continue
            }

            setValue(headerValue, forHTTPHeaderField: field)
        }
    }
}
