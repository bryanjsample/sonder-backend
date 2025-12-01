// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SonderBackend",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(
            url: "https://github.com/vapor/fluent-postgres-driver.git",
            from: "2.8.0"
        ),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🔐 Federated Authentication with OAuth providers for Vapor
        .package(
            url: "https://github.com/vapor-community/Imperial.git",
            from: "2.0.0"
        ),
        // 📀 Data Transfer Objects to interacts with both ends
        .package(name: "SonderDTOs", path: "../SonderDTOs"),
    ],
    targets: [
        .executableTarget(
            name: "SonderBackend",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(
                    name: "FluentPostgresDriver",
                    package: "fluent-postgres-driver"
                ),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "ImperialGoogle", package: "imperial"),
                .product(name: "SonderDTOs", package: "SonderDTOs"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SonderBackendTests",
            dependencies: [
                .target(name: "SonderBackend"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny")
    ]
}
