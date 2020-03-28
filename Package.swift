// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "VVJSONSchemaValidation",
    platforms: [.iOS(.v8), .tvOS(.v9), .watchOS(.v2), .macOS(.v10_10)],
    products: [
        .library(
            name: "VVJSONSchemaValidation",
            targets: ["VVJSONSchemaValidation"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VVJSONSchemaValidation",
            dependencies: [],
            path: "VVJSONSchemaValidation"
        )
    ]
)
