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
            url: "https://github.com/poedit/embedded-python/releases/download/v3.13.13/Python.xcframework.zip",
            checksum: "85893b9f513810c422be84c2fb787c0b6ecdf9182979b9ac60aff5c61d982650"
        ),
    ]
)
