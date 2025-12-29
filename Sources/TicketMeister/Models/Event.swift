import Fluent
import Vapor

final class Event: Model, Authenticatable, Content, @unchecked Sendable {
  static let schema = "events"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String

  @Parent(key: "venue")
  var venue: Venue

  @Timestamp(key: "start", on: .none)
  var start: Date?

  @Children(for: \.$event)
  var tickets: [Ticket]

  init() {}

  init(
    id: UUID?,
    name: String,
    venue: Venue,
    start: Date
  ) {
    self.id = id
    self.name = name
    self.venue = venue
    self.start = start
  }

  func toDto() -> EventDTO {
    .init(
      id: id,
      name: name,
      start: start)
  }
}
