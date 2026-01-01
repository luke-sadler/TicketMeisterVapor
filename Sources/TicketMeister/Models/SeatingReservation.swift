import Fluent
import Vapor

final class SeatingReservation: Model,
  Authenticatable,
  Content,
  @unchecked Sendable,
  DTORepresentable
{
  static let schema = "seat_reservation"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user")
  var user: User

  @Parent(key: "event")
  var event: Event

  @Parent(key: "seat")
  var seat: Seat

  @Timestamp(key: "created", on: .create)
  var created: Date?

  @Timestamp(key: "expires", on: .none)
  var expires: Date?

  init() {}

  init(user: UUID, event: UUID, seat: UUID, expires: Date) {
    self._user.id = user
    self._event.id = event
    self._seat.id = seat
    self.expires = expires
  }

  func toDto() -> SeatingReservationDTO {
    .init(
      id: id,
      user: user.toDto(),
      seat: seat.toDto(),
      event: event.toDto(),
      created: created,
      expires: expires)
  }

}
