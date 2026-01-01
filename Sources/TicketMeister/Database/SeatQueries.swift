import Fluent
import Foundation

struct SeatQueries: DatabaseQuery {
  typealias T = Seat
}

extension SeatQueries {
  // static func seatingAtEventVenue(_ venueId: UUID, on db: any Database) async throws -> [Seat] {
  //   try await T.query(on: db)
  //     .join(SeatGroup.self, on: \Seat.$section.$id == \SeatGroup.$id)
  //     .filter(SeatGroup.self, \.$venue.$id == venueId)
  //     .with(\.$section) { $0.with(\.$priceGroup) }
  //     .all()
  // }
}
