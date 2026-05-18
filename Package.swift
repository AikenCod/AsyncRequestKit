// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AsyncRequestKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "AsyncRequestKit",
            targets: ["AsyncRequestKit"]
        ),
        .executable(
            name: "AsyncRequestKitDemo",
            targets: ["AsyncRequestKitDemo"]
        )
    ],
    targets: [
        .target(
            name: "AsyncRequestKit"
        ),
        .executableTarget(
            name: "AsyncRequestKitDemo",
            dependencies: ["AsyncRequestKit"],
            path: "Sources/AsyncRequestKitDemo"
        ),
        .testTarget(
            name: "AsyncRequestKitTests",
            dependencies: ["AsyncRequestKit"]
        )
    ]
)
