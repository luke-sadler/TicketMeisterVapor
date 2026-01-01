import Vapor

struct PurchaseTicketDTO: Codable, Content {
  let user: UUID
  let reservation: UUID
}
