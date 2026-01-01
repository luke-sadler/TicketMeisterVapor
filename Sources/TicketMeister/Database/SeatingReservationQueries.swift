import Fluent
import Foundation
import Vapor

struct SeatingReservationsQueries: DatabaseQuery {
  typealias T = SeatingReservation
}

extension SeatingReservationsQueries {
  static func seatingReservationsAlreadyExists(
    seat: UUID,
    event: UUID,
    on db: any Database
  ) async throws -> Bool {

    try await SeatingReservation.query(on: db)
      .filter(\.$seat.$id == seat)
      .filter(\.$event.$id == event)
      .filter(\.$expires > Date())
      .count() > 0
  }

  static func fullGet(id: UUID, on db: any Database) async throws -> SeatingReservation {
    try await SeatingReservation.query(on: db)
      .filter(\.$id == id)
      .with(\.$seat) { $0.with(\.$section) { $0.with(\.$priceGroup) } }
      .with(\.$user)
      .with(\.$event)
      .first()
      .unwrap(or: Abort(.internalServerError))
  }

  @discardableResult
  static func removeExpiredReservations(on db: any Database) async throws -> Int {
    let expired = try await SeatingReservation.query(on: db)
      .filter(\.$expires < Date())
      .all()

    try await expired.delete(on: db)
    return expired.count
  }
}
