import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct EmptyResponse: Decodable, Equatable, Sendable {
    public init() {}
}

public struct HTTPResponse<Value> {
    public let value: Value
    public let data: Data
    public let response: HTTPURLResponse

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
