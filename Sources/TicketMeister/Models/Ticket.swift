import Fluent
import Vapor

final class Ticket: Model,
  Authenticatable,
  Content,
  @unchecked Sendable,
  DTORepresentable
{
  static let schema = "tickets"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "user")
  var user: User

  @Parent(key: "seat")
  var seat: Seat

  @Parent(key: "event")
  var event: Event

  init() {}

  init(reservation: SeatingReservation) {
    self._user.id = reservation.user.id!
    self._seat.id = reservation.seat.id!
    self._event.id = reservation.event.id!
  }

  func toDto() -> TicketDTO {

    return .init(
      id: id,
      user: user.toDto(),
      seat: seat.toDto(),
      event: event.toLiteDto())
  }

}
