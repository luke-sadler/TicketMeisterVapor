import Fluent
import Foundation

struct SeatGroupQueries: DatabaseQuery {
  typealias T = SeatGroup
}

extension SeatGroupQueries {

  static func getSeatGroupsAtVenue(
    _ venueId: UUID,
    on db: any Database
  ) async throws -> [SeatGroup] {
    try await SeatGroup.query(on: db)
      .filter(\.$venue.$id == venueId)
      .with(\.$priceGroup)
      .with(\.$seats)
      .all()
  }

}
