import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(
        DatabaseConfigurationFactory.postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5454,  // ?? SQLPostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "luke",
                password: Environment.get("DATABASE_PASSWORD") ?? "2few3rf3i8!",
                database: Environment.get("DATABASE_NAME") ?? "tickets",
                tls: .prefer(try .init(configuration: .clientDefault)))
        ), as: .psql)

    app.migrations.add(CreateVenues())
    app.migrations.add(CreatePriceGroup())
    app.migrations.add(CreateSeatSections())
    app.migrations.add(CreateSeating())
    app.migrations.add(CreateEvents())
    app.migrations.add(CreateTickets())

    try await app.autoMigrate()

    // register routes
    try routes(app)
}
