// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AppUI",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "AppUI",
            targets: ["AppUI"]
        )
    ],
    targets: [
        .target(
            name: "AppUI"
        )
    ]
)
