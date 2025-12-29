import Fluent
import Foundation

struct VenueQueries: DatabaseQuery {
  typealias T = Venue
}

extension VenueQueries {

  static func getFull(id: UUID, _ db: any Database) async throws -> Venue? {
    try await Venue.query(on: db)
      .with(\.$seatGroup) { $0.with(\.$seats).with(\.$priceGroup) }
      .with(\.$events)
      .filter(\.$id == id)
      .first()
  }

}
