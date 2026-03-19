// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "NetworkKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        )
    ],
    targets: [
        .target(name: "NetworkKit"),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit"]
        )
    ]
)
