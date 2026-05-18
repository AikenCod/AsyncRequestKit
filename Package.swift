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
        )
    ],
    targets: [
        .target(
            name: "AsyncRequestKit"
        ),
        .testTarget(
            name: "AsyncRequestKitTests",
            dependencies: ["AsyncRequestKit"]
        )
    ]
)
