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
        .package(path: "../NetworkKit"),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-custom-dump",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "BreedDetails",
            dependencies: [
                "DesignKit",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .target(
            name: "BreedsFeature",
            dependencies: [
                "DesignKit",
                "BreedDetails",
                "NetworkKit",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ]
        ),
        .testTarget(
            name: "BreedsFeatureTests",
            dependencies: [
                "BreedsFeature",
                .product(
                    name: "CustomDump",
                    package: "swift-custom-dump"
                ),
                .product(
                    name: "DependenciesTestSupport",
                    package: "swift-dependencies"
                ),
            ]
        )
    ]
)
