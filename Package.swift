// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftPGP",
    products: [
        .library(
            name: "SwiftPGP",
            targets: ["SwiftPGP"]),
    ],
    dependencies: [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SwiftPGP",
            dependencies: []),
        .testTarget(
            name: "SwiftPGPTests",
            dependencies: ["SwiftPGP"],
            path: "./Tests",
            resources: [.process("Testfiles")]),
    ]
)
