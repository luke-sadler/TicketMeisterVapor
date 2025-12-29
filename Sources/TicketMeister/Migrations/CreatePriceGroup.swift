import Fluent

struct CreatePriceGroup: AsyncMigration {
  func prepare(on database: any Database) async throws {
    try await database.schema("price_group")
      .id()
      .field("title", .string, .required)
      .field("value", .double, .required)
      .create()
  }

  func revert(on database: any Database) async throws {
    try await database.schema("price_group").delete()
  }
}
