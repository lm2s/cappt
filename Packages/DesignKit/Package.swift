// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "DesignKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DesignKit",
            targets: ["DesignKit"]
        )
    ],
    dependencies: [
        .package(path: "../NetworkKit"),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "DesignKit",
            dependencies: [
                "NetworkKit",
                .product(
                    name: "Dependencies",
                    package: "swift-dependencies"
                ),
            ]
        )
    ]
)
