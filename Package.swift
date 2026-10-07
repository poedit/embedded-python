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
            url: "https://github.com/poedit/embedded-python/releases/download/v3.14.8/Python.xcframework.zip",
            checksum: "0eb65a4632917afc4d2d3c703cc3c6cc7fb180abfbbe3cf4d088c35c6e3ea949"
        ),
    ]
)
