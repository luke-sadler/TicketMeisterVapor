import Fluent

struct CreateTickets: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("tickets")
      .id()
      .field("seat", .uuid, .required, .references("seating", "id", onDelete: .cascade))
      .field("event", .uuid, .required, .references("events", "id", onDelete: .cascade))
      .field("user", .uuid, .required, .references("users", "id", onDelete: .cascade))
      .unique(on: "seat", "event")
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("tickets").delete()
  }
}
