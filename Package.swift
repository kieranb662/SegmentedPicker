// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "SegmentedPicker",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SegmentedPicker",
            targets: ["SegmentedPicker"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kieranb662/Shapes.git", from: "1.0.4"),
        .package(url: "https://github.com/kieranb662/CGExtender.git", from: "1.0.3")
    ],
    targets: [
        .target(
            name: "SegmentedPicker",
            dependencies: ["CGExtender", "Shapes"])
    ]
)
