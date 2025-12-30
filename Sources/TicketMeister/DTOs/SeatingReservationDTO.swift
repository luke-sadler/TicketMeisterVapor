import Vapor

struct SeatingReservationDTO: Codable, Content {

  let id: UUID?
  let seat: SeatDTO
  let event: EventDTO
  let created: Date?
  let expires: Date?
}
