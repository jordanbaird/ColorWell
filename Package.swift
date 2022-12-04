// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "ColorWell",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "ColorWell",
            targets: ["ColorWell"]
        ),
    ],
    targets: [
        .target(
            name: "ColorWell",
            dependencies: [],
            resources: [
                .copy("Resources/Colors.xcassets"),
            ]
        ),
        .testTarget(
            name: "ColorWellTests",
            dependencies: ["ColorWell"]
        ),
    ]
)
