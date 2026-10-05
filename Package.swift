// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Stellina",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "Stellina",
            targets: ["Stellina"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Stellina",
            dependencies: [],
            path: "Sources/Stellina"
        )
    ]
)
