import Vapor

struct MakeReservationDTO: Codable, Content {
  let user: UUID
  let seat: UUID
  let event: UUID
}
