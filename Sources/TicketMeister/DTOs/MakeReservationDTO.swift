import Vapor

struct MakeReservationDTO: Codable, Content {

  let seat: UUID
  let event: UUID

}
