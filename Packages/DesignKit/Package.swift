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
    targets: [
        .target(name: "DesignKit")
    ]
)
