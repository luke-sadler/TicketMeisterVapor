import Vapor

struct EventSeatSectionDTO: Content {
  let id: UUID
  let name: String
  let position: Int
  let seats: [EventSeatDTO]
}
