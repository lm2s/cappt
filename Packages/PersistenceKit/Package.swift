// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PersistenceKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PersistenceKit",
            targets: ["PersistenceKit"]
        )
    ],
    targets: [
        .target(name: "PersistenceKit")
    ]
)
