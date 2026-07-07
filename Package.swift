// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ParlangDemo",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ParlangDemo", targets: ["ParlangDemo"])
    ],
    targets: [
        .executableTarget(name: "ParlangDemo")
    ]
)
