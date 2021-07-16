// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SettingsKit",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SettingsKit",
            targets: ["SettingsKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/lucamegh/Storage", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SettingsKit",
            dependencies: ["Storage"]
        ),
        .testTarget(
            name: "SettingsKitTests",
            dependencies: ["SettingsKit"]
        )
    ]
)
