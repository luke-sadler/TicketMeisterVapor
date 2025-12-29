import Vapor

struct VenueDTO: Codable, Content {
  let id: UUID?
  let currency: String
  let title: String
  let events: [EventDTO]?
  let seatsGroup: [SeatGroupDTO]?
}
