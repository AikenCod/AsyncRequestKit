# Multipart Uploads

`HTTPClient` and `AK` provide in-memory `multipart/form-data` uploads. Use them
for small payloads whose complete encoded body can safely fit in memory.

## Upload and decode a response

```swift
import AsyncRequestKit
import Foundation

struct UploadResult: Decodable {
    let id: String
    let url: URL
}

let client = HTTPClient(
    configuration: HTTPClientConfiguration(
        baseURL: URL(string: "https://api.example.com")!,
        timeout: .seconds(30)
    )
)

let result: UploadResult = try await client.upload(
    "/uploads",
    headers: ["X-Request-ID": UUID().uuidString],
    multipart: { form in
        form.append("avatar", name: "purpose")
        form.append(
            imageData,
            name: "file",
            fileName: "avatar.jpg",
            mimeType: "image/jpeg"
        )
    }
)
```

Text fields are UTF-8 encoded. For binary fields, supply the server's expected
field name, filename, and MIME type. If a MIME type is omitted from the file
helpers, `application/octet-stream` is used.

To read headers and status metadata along with a decoded body, use
`uploadResponse`:

```swift
let response: HTTPResponse<UploadResult> = try await client.uploadResponse(
    "/uploads",
    multipart: { form in
        form.append(
            fileURL: localFileURL,
            name: "file",
            mimeType: "application/pdf"
        )
    }
)

print(response.response.statusCode)
print(response.value.id)
```

The file-URL overload reads the entire file into `Data`, and encoding creates a
complete request body in memory. AsyncRequestKit does not currently provide a
streaming or background upload API. For large files, use a streaming-capable
transport instead of this helper.

By default, non-2xx responses throw
`HTTPClientError.unacceptableStatusCode(statusCode, data)`. Inspect the status
and preserved body to distinguish server size limits such as 413 from other
validation failures. A client timeout cancels the request task, but server-side
limits and cleanup behavior still need integration tests against your service.
