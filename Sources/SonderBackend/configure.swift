import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.middleware.use(app.sessions.middleware)

    app.databases.use(
        DatabaseConfigurationFactory.postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
                    ?? SQLPostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "bryan",
                password: Environment.get("DATABASE_PASSWORD") ?? "testing",
                database: Environment.get("DATABASE_NAME") ?? "sonder_testing",
                tls: .prefer(try .init(configuration: .clientDefault))
            )
        ),
        as: .psql
    )

    //    if app.environment == .testing {
    app.logger.logLevel = .debug
    //    } else {
    //        app.logger.logLevel = .info
    //    }
    app.migrations.add(CreateCircle())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAccessToken())
    app.migrations.add(CreateRefreshToken())
    app.migrations.add(CreateCalendarEvent())
    app.migrations.add(CreatePost())
    app.migrations.add(CreateComment())
    if app.environment == .testing {
        app.migrations.add(MakeTestCircle())
    }

    // register routes
    try routes(app)

    app.get("debug", "routes") { req -> String in
        let lines = req.application.routes.all.map { route in
            let path = route.path.map(\.description).joined(separator: "/")
            return "\(route.method.rawValue) /\(path)"
        }
        return lines.sorted().joined(separator: "\n")
    }
}
