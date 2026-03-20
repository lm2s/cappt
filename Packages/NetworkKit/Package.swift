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
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(
                    name: "Dependencies",
                    package: "swift-dependencies"
                ),
            ]
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit"]
        )
    ]
)
