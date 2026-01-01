import Fluent
import Vapor

enum ChangeError: Error {
  case unableToFind
  case alreadyOnHold
  case alreadySold
}

final class Venue: Model,
  Authenticatable,
  Content,
  @unchecked Sendable,
  DTORepresentable
{
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

}
