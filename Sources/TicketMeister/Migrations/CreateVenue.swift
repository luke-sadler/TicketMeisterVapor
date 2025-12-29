import Fluent

struct CreateVenues: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("venues")
            .id()
            .field("title", .string, .required)
            .field("currency", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("venues").delete()
    }
}
