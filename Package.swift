// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "FailableSequence",
    products: [
        .library(
            name: "FailableSequence",
            targets: ["FailableSequence"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FailableSequence",
            dependencies: []),
        .testTarget(
            name: "FailableSequenceTests",
            dependencies: ["FailableSequence"]),
    ]
)
