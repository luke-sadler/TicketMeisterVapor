import Vapor

struct VenueDTO: Codable, Content {
  let name: String
  let seats: [SeatDTO]
}
