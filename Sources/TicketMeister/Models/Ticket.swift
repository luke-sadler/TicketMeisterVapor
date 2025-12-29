import Fluent
import Vapor

final class Ticket: Model, Authenticatable, Content, @unchecked Sendable {
  static let schema = "tickets"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "seat")
  var seat: Seat

  @Parent(key: "event")
  var event: Event

  init() {}

}
