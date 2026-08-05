// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Time4Shared",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "Time4Shared", targets: ["Time4Shared"])
    ],
    targets: [
        .target(name: "Time4Shared"),
        .testTarget(name: "Time4SharedTests", dependencies: ["Time4Shared"])
    ]
)
