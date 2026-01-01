import Fluent
import Vapor

struct CreateUsers: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("users")
      .id()
      .field("username", .string, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("users").delete()
  }
}
