import Fluent
import Vapor

enum ChangeError: Error {
  case unableToFind
  case alreadyOnHold
  case alreadySold
}

final class Venue: Model, Authenticatable, Content, @unchecked Sendable {
  static let schema = "venues"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "currency")
  var currency: String

  @Field(key: "title")
  var title: String

  @Children(for: \.$venue)
  var events: [Event]

  @Children(for: \.$venue)
  var seatGroup: [SeatGroup]

  init() {}

  init(
    id: UUID?,
    currency: String,
    title: String
  ) {
    self.id = id
    self.currency = currency
    self.title = title
  }

  func toLiteDto() -> VenueDTO {
    .init(
      id: id,
      currency: currency,
      title: title,
      events: nil,
      seatsGroup: nil)
  }

  func toDto() -> VenueDTO {
    .init(
      id: id,
      currency: currency,
      title: title,
      events: events.map { $0.toDto() },
      seatsGroup: seatGroup.map { $0.toDto() })
  }

  // init()

  // private func updateSeat(_ idx: Array<Int>.Index, _ new: Seat) {
  //   seating.remove(at: idx)
  //   seating.insert(new, at: idx)
  // }

  // func releaseSeat(request: SeatRequest) throws -> Seat {
  //   if let idx = self.seating.firstIndex(where: { $0 ~= request }) {
  //     let seat = seating[idx]
  //     let new = Seat(row: request.row, col: request.col, status: .available)
  //     updateSeat(idx, new)
  //     return new
  //   }

  //   throw ChangeError.unableToFind
  // }

  // func holdSeat(request: SeatRequest) throws -> Seat {
  //   if let idx = self.seating.firstIndex(where: { $0 ~= request }) {
  //     let seat = seating[idx]
  //     switch seat.status {
  //     case .available:
  //       let new = Seat(row: request.row, col: request.col, status: .onHold)
  //       updateSeat(idx, new)
  //       return new
  //     case .onHold: throw ChangeError.alreadyOnHold
  //     case .sold: throw ChangeError.alreadySold
  //     }
  //   }
  //   throw ChangeError.unableToFind
  // }

  // func toDto() -> VenueDTO {
  //   .init(
  //     name: name,
  //     seats: seating.map { $0.toDto() })
  // }
}
