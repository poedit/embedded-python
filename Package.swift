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
            url: "https://github.com/poedit/embedded-python/releases/download/v3.14.7/Python.xcframework.zip",
            checksum: "0f222c070499a815de4cbd57708af612a4561e950167308464fcf1feabb336b1"
        ),
    ]
)
