// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AppUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AppUI",
            targets: ["AppUI"]
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
            name: "AppUI",
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
