import Vapor

struct EventDTO: Codable, Content {
  let id: UUID?
  let name: String
  // let venue: VenueDTO?
  let start: Date?
}
