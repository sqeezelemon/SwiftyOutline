// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyOutline",
    platforms: [
      .iOS(.v15),
      .macOS(.v12)
    ],
    products: [
      .library(name: "SwiftyOutline", targets: ["SwiftyOutline"])
    ],
    targets: [
      .target(name: "SwiftyOutline", path: "Sources")
    ]
)
