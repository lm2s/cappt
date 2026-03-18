// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "BreedsFeature",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BreedsFeature",
            targets: ["BreedsFeature"]
        )
    ],
    dependencies: [
        .package(path: "../DesignKit"),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "BreedsFeature",
            dependencies: [
                "DesignKit",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        )
    ]
)
