import Fluent

struct CreateEvents: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("events")
      .id()
      .field("name", .string, .required)
      .field("venue", .uuid, .references("venues", "id", onDelete: .cascade), .required)
      .field("start", .datetime)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("events").delete()
  }
}
