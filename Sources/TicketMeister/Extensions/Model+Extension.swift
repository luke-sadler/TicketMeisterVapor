import Fluent
import Foundation

extension Model where IDValue == UUID {
  static func get(
    _ id: UUID,
    on db: any Database
  ) async throws -> Self? {
    try await query(on: db)
      .filter(\Self._$id == id)
      .first()
  }
}
