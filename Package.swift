// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContentaVersionModel",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ContentaVersionModel",
            targets: ["ContentaVersionModel"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vitolibrarius/ContentaTools.git", from: "0.0.0"),
    ],
    targets: [
        .target(name: "ContentaVersionModel", dependencies: [
            "Fluent",
            "Vapor",
            "ContentaTools"
        ]),
        .testTarget(name: "ContentaVersionModelTests", dependencies: [
            "FluentSQLite",
            "ContentaVersionModel"
        ]),
    ]
)
