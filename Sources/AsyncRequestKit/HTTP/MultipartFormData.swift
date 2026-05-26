import Foundation

public struct MultipartFormData: Sendable {
    public struct Part: Sendable {
        public let name: String
        public let fileName: String?
        public let mimeType: String?
        public let data: Data

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

    public private(set) var parts: [Part] = []

    public init() {}

    public mutating func append(_ value: String, name: String) {
        append(Data(value.utf8), name: name)
    }

    public mutating func append(_ data: Data, name: String) {
        parts.append(Part(name: name, data: data))
    }

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
