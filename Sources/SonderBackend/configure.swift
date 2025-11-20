import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "bryan",
        password: Environment.get("DATABASE_PASSWORD") ?? "testing",
        database: Environment.get("DATABASE_NAME") ?? "sonder_testing",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    if app.environment == .testing {
        app.logger.logLevel = .debug
    } else {
        app.logger.logLevel = .info
    }
    app.migrations.add(CreateCircle())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateCalendarEvent())
    app.migrations.add(CreatePost())
    app.migrations.add(CreateComment())

    // register routes
    try routes(app)
}
