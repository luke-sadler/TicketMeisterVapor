import Vapor

struct TicketDTO: Codable, Content {
  let id: UUID?
  let user: UserDTO
  let seat: SeatDTO
  let event: EventLiteDTO
}
