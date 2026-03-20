// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PersistenceKit",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "PersistenceKit",
            targets: ["PersistenceKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.0.0"
        )
    ],
    targets: [
        .target(
            name: "PersistenceKit",
            dependencies: [
                .product(
                    name: "Dependencies",
                    package: "swift-dependencies"
                )
            ],
            resources: [
                .process("CoreData/CapptModel.xcdatamodeld")
            ]
        )
    ]
)
