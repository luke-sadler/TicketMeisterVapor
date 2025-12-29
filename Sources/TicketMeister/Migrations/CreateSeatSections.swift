import Fluent

struct CreateSeatSections: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("seat_section")
      .id()
      .field("name", .string, .required)
      .field("position", .uint32, .required)
      .field("price_group", .uuid, .required, .references("price_group", "id", onDelete: .cascade))
      .field("venue", .uuid, .required, .references("venues", "id", onDelete: .cascade))
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("seat_section").delete()
  }
}
