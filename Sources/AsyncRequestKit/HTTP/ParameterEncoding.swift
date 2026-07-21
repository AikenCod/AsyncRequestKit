import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Dictionary parameters accepted by the built-in encoders.
public typealias Parameters = [String: Any]

/// A strategy that mutates a URL request to contain dictionary parameters.
public protocol ParameterEncoding {
    /// Encodes parameters into a request.
    func encode(_ request: inout URLRequest, with parameters: Parameters?) throws
}

/// Errors produced by built-in parameter encoders.
public enum ParameterEncodingError: Error, Equatable {
    /// Query encoding required a request URL, but none was present.
    case missingURL
    /// A parameter value could not be represented by the selected encoder.
    case invalidJSONObject
}

/// Encodes parameters as a JSON request body.
public struct JSONEncoding: ParameterEncoding, Sendable {
    /// A reusable default JSON encoder.
    public static let `default` = JSONEncoding()

    /// Creates a JSON parameter encoder.
    public init() {}

    /// Encodes a valid JSON object and supplies JSON content headers when absent.
    public func encode(_ request: inout URLRequest, with parameters: Parameters?) throws {
        guard let parameters else {
            return
        }

        guard JSONSerialization.isValidJSONObject(parameters) else {
            throw ParameterEncodingError.invalidJSONObject
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if request.value(forHTTPHeaderField: "Accept") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
    }
}

/// Encodes nested parameters as URL query items or a form-encoded body.
public struct URLEncoding: ParameterEncoding, Sendable {
    /// The location where encoded parameters are written.
    public enum Destination: Sendable {
        /// Use the query for GET, HEAD, and DELETE; otherwise use the body.
        case methodDependent
        /// Always append parameters to the URL query.
        case queryString
        /// Always write parameters to the request body.
        case httpBody
    }

    public static let `default` = URLEncoding()
    public static let queryString = URLEncoding(destination: .queryString)
    public static let httpBody = URLEncoding(destination: .httpBody)

    /// The destination selected for this encoder.
    public let destination: Destination

    /// Creates a URL encoder.
    public init(destination: Destination = .methodDependent) {
        self.destination = destination
    }

    /// Encodes dictionaries and arrays using bracket notation.
    public func encode(_ request: inout URLRequest, with parameters: Parameters?) throws {
        guard let parameters, !parameters.isEmpty else {
            return
        }

        let destination = resolvedDestination(for: request)
        let components = try queryComponents(fromKey: nil, value: parameters)

        switch destination {
        case .queryString:
            guard let url = request.url else {
                throw ParameterEncodingError.missingURL
            }

            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw ParameterEncodingError.missingURL
            }

            var queryItems = urlComponents.queryItems ?? []
            queryItems.append(contentsOf: components.map(URLQueryItem.init))
            urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems
            request.url = urlComponents.url
        case .httpBody:
            request.httpBody = query(from: components).data(using: .utf8)

            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue(
                    "application/x-www-form-urlencoded; charset=utf-8",
                    forHTTPHeaderField: "Content-Type"
                )
            }
        case .methodDependent:
            break
        }
    }

    private func resolvedDestination(for request: URLRequest) -> Destination {
        switch destination {
        case .methodDependent:
            guard let method = request.httpMethod?.uppercased() else {
                return .queryString
            }

            switch method {
            case "GET", "HEAD", "DELETE":
                return .queryString
            default:
                return .httpBody
            }
        case .queryString, .httpBody:
            return destination
        }
    }

    private func query(from components: [(String, String)]) -> String {
        components
            .map { "\(escape($0.0))=\(escape($0.1))" }
            .joined(separator: "&")
    }

    private func queryComponents(fromKey key: String?, value: Any) throws -> [(String, String)] {
        switch value {
        case let dictionary as [String: Any]:
            return try dictionary.keys.sorted().flatMap { nestedKey in
                try queryComponents(
                    fromKey: key.map { "\($0)[\(nestedKey)]" } ?? nestedKey,
                    value: dictionary[nestedKey] as Any
                )
            }
        case let array as [Any]:
            return try array.flatMap { item in
                try queryComponents(fromKey: "\(key ?? "")[]", value: item)
            }
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return [(try requireKey(key), number.boolValue ? "1" : "0")]
            }

            return [(try requireKey(key), number.stringValue)]
        case let string as String:
            return [(try requireKey(key), string)]
        case _ as NSNull:
            return [(try requireKey(key), "")]
        default:
            throw ParameterEncodingError.invalidJSONObject
        }
    }

    private func requireKey(_ key: String?) throws -> String {
        guard let key else {
            throw ParameterEncodingError.invalidJSONObject
        }

        return key
    }

    private func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        let allowed = CharacterSet.urlQueryAllowed.subtracting(
            CharacterSet(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        )

        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
    }
}
