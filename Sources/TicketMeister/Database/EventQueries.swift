import Fluent
import Foundation

struct EventQueries: DatabaseQuery {
  typealias T = Event
}

extension EventQueries {

  static func eventsAtVenue(_ id: UUID, on db: any Database) async throws -> [Event] {
    try await T.query(on: db)
      .filter(\.$venue.$id == id)
      .all()
  }

  static func getEvent(_ id: UUID, on db: any Database) async throws -> Event? {
    try await T.query(on: db)
      .filter(\.$id == id)
      .with(\.$venue)
      .first()
  }

  static func getEvents(on db: any Database) async throws -> [Event] {
    try await T.query(on: db)
      .with(\.$venue)
      .all()
  }

}
