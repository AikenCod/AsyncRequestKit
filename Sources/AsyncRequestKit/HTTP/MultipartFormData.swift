import Foundation

/// An in-memory collection of fields encoded as `multipart/form-data`.
public struct MultipartFormData: Sendable {
    /// A single text or binary form part.
    public struct Part: Sendable {
        /// The form field name.
        public let name: String
        /// The optional filename sent in the content disposition.
        public let fileName: String?
        /// The optional media type for the part.
        public let mimeType: String?
        /// The unencoded body data for the part.
        public let data: Data

        /// Creates a form part.
        public init(
            name: String,
            fileName: String? = nil,
            mimeType: String? = nil,
            data: Data
        ) {
            self.name = name
            self.fileName = fileName
            self.mimeType = mimeType
            self.data = data
        }
    }

    /// The parts in insertion order.
    public private(set) var parts: [Part] = []

    /// Creates an empty form.
    public init() {}

    /// Appends a UTF-8 text field.
    public mutating func append(_ value: String, name: String) {
        append(Data(value.utf8), name: name)
    }

    /// Appends an unnamed binary field without filename or media-type metadata.
    public mutating func append(_ data: Data, name: String) {
        parts.append(Part(name: name, data: data))
    }

    /// Appends an in-memory file field.
    public mutating func append(
        _ data: Data,
        name: String,
        fileName: String,
        mimeType: String = "application/octet-stream"
    ) {
        parts.append(
            Part(
                name: name,
                fileName: fileName,
                mimeType: mimeType,
                data: data
            )
        )
    }

    /// Reads and appends a local file.
    public mutating func append(
        fileURL: URL,
        name: String,
        fileName: String? = nil,
        mimeType: String = "application/octet-stream"
    ) throws {
        let data = try Data(contentsOf: fileURL)
        append(
            data,
            name: name,
            fileName: fileName ?? fileURL.lastPathComponent,
            mimeType: mimeType
        )
    }

    func encodedData(boundary: String) -> Data {
        var data = Data()

        for part in parts {
            data.append("--\(boundary)\r\n")
            data.append(contentDisposition(for: part))
            data.append("\r\n")

            if let mimeType = part.mimeType {
                data.append("Content-Type: \(mimeType)\r\n")
            }

            data.append("\r\n")
            data.append(part.data)
            data.append("\r\n")
        }

        data.append("--\(boundary)--\r\n")
        return data
    }

    private func contentDisposition(for part: Part) -> String {
        var disposition = "Content-Disposition: form-data; name=\"\(escape(part.name))\""

        if let fileName = part.fileName {
            disposition += "; filename=\"\(escape(fileName))\""
        }

        return disposition
    }

    private func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}

private extension Data {
    mutating func append(_ string: String) {
        append(contentsOf: string.utf8)
    }
}
