#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_root="$(mktemp -d)"
trap 'rm -rf "$fixture_root"' EXIT

cd "$fixture_root"
swift package init --type executable --name AsyncRequestKitConsumer >/dev/null

cat > Package.swift <<EOF
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AsyncRequestKitConsumer",
    platforms: [.macOS(.v13)],
    dependencies: [.package(name: "AsyncRequestKit", path: "$repo_root")],
    targets: [
        .executableTarget(
            name: "AsyncRequestKitConsumer",
            dependencies: [.product(name: "AsyncRequestKit", package: "AsyncRequestKit")]
        )
    ]
)
EOF

cat > Sources/main.swift <<'EOF'
import AsyncRequestKit
import Foundation

let client = HTTPClient(configuration: HTTPClientConfiguration())
print(String(describing: client))
EOF

swift build
