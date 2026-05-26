// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ZLForm",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "ZLForm",
            targets: ["ZLForm"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ra1028/DifferenceKit.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "ZLForm",
            dependencies: [
                .product(name: "DifferenceKit", package: "DifferenceKit")
            ],
            path: "ZLForm/Classes"
        )
    ]
)