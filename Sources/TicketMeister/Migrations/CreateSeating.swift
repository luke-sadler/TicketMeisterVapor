import Fluent

struct CreateSeating: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("seating")
      .id()
      .field("section", .uuid, .required, .references("seat_section", "id", onDelete: .cascade))
      .field("number", .uint32, .required)
      .field("status", .string, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("seating").delete()
  }
}
