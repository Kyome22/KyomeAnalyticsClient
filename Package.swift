// swift-tools-version: 6.2

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "KyomeAnalyticsClient",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "KyomeAnalyticsClient",
            targets: ["KyomeAnalyticsClient"]
        ),
    ],
    targets: [
        .target(
            name: "KyomeAnalyticsClient",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "KyomeAnalyticsClientTests",
            dependencies: ["KyomeAnalyticsClient"],
            swiftSettings: swiftSettings
        ),
    ]
)
