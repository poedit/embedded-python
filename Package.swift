// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Python",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Python",
            targets: ["Python"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "Python",
            url: "https://github.com/poedit/python-framework/releases/download/v3.13.13/Python.xcframework.zip",
            checksum: "0000000000000000000000000000000000000000000000000000000000000000"
        ),
    ]
)
