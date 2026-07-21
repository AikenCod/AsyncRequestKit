import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A decodable marker for successful responses that do not contain a body.
public struct EmptyResponse: Decodable, Equatable, Sendable {
    /// Creates an empty response value.
    public init() {}
}

/// A decoded value together with its original data and HTTP metadata.
public struct HTTPResponse<Value> {
    /// The decoded response value.
    public let value: Value
    /// The unmodified response body.
    public let data: Data
    /// The HTTP response metadata.
    public let response: HTTPURLResponse

    /// Creates a metadata-preserving response value.
    public init(value: Value, data: Data, response: HTTPURLResponse) {
        self.value = value
        self.data = data
        self.response = response
    }
}

protocol EmptyResponseRepresentable {
    static func emptyValue() -> Self
}

extension EmptyResponse: EmptyResponseRepresentable {
    static func emptyValue() -> Self {
        Self()
    }
}
