import Fluent
import Vapor

final class SeatingReservation: Model, Authenticatable, Content, @unchecked Sendable {
  static let schema = "seat_reservation"

  @ID(key: .id)
  var id: UUID?

  // @Field(key: "user")

  @Parent(key: "event")
  var event: Event

  @Parent(key: "seat")
  var seat: Seat

  @Timestamp(key: "created", on: .create)
  var created: Date?

  init() {}

  init(event: UUID, seat: UUID) {
    self._event.id = event
    self._seat.id = seat
  }

  func toDto() -> SeatingReservationDTO {
    .init(
      id: id,
      seat: seat.toDto(),
      event: event.toDto(),
      created: created,
      expires: Date())  // TODO: Update model?
  }

}
