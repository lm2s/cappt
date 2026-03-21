// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "BreedsFeature",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "BreedsFeature",
            targets: ["BreedsFeature"]
        )
    ],
    dependencies: [
        .package(path: "../AppUI"),
        .package(path: "../NetworkKit"),
        .package(path: "../PersistenceKit"),
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
                "AppUI",
                "NetworkKit",
                "PersistenceKit",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ],
            path: "Sources/BreedDetails",
            resources: [.process("Resources")]
        ),
        .target(
            name: "BreedsFeature",
            dependencies: [
                "AppUI",
                "BreedDetails",
                "NetworkKit",
                "PersistenceKit",
                .product(
                    name: "ComposableArchitecture",
                    package: "swift-composable-architecture"
                ),
            ],
            path: "Sources",
            exclude: [
                "BreedDetails",
            ],
            sources: [
                "BreedsFeature",
                "Domain/BreedsEndpoint.swift",
                "Domain/BreedsService.swift",
            ],
            resources: [.process("Resources")]
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
