import Fluent

struct CreateSeatReservations: AsyncMigration {

  func prepare(on database: any Database) async throws {
    try await database.schema("seat_reservation")
      .id()
      .field("event", .uuid, .references("events", "id", onDelete: .cascade), .required)
      .field("seat", .uuid, .references("seating", "id", onDelete: .cascade), .required)
      .field("created", .datetime, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("seat_reservation").delete()
  }
}
