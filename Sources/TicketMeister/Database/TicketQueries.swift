import Fluent
import Foundation
import Vapor

struct TicketQueries: DatabaseQuery {
  typealias T = Ticket
}

extension TicketQueries {

  static func ticketAlreadySold(_ seat: UUID, _ event: UUID, on db: any Database) async throws
    -> Bool
  {
    try await Ticket.query(on: db)
      .filter(\.$seat.$id == seat)
      .filter(\.$event.$id == event)
      .count() > 0
  }

  static func getFull(_ id: UUID, on db: any Database) async throws -> Ticket {
    try await T.query(on: db)
      .with(\.$event) { $0.with(\.$venue) }
      .with(\.$seat) { $0.with(\.$section) { $0.with(\.$priceGroup) } }
      .with(\.$user)
      .first()
      .unwrap(or: Abort(.internalServerError))
  }

  /// Gets [UUID] for all seats associated with all tickets for a given event.
  static func getTicketSeatsForEvent(_ eventId: UUID, on db: any Database) async throws -> [UUID] {
    try await T.query(on: db)
      .filter(\.$event.$id == eventId)
      .all(\.$seat.$id)
  }

}
