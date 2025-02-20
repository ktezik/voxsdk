// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VOXSDK",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "VOXSDK", targets: ["VOXSDK"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VOXSDK",
            dependencies: [],
            path: "VOXSDK/Sources",
            exclude: ["ExampleApp", "README.md", "VOXSDK.xcodeproj"],
            swiftSettings: [
                .define("SWIFT_VERSION_5")
            ]
        )
    ]
)
