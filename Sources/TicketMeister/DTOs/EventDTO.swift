import Vapor

struct EventLiteDTO: Codable, Content {
  let id: UUID?
  let name: String
  let start: Date?
}

struct EventDTO: Codable, Content {

  let id: UUID?
  let name: String
  let start: Date?
  let venue: VenueDTO
}
