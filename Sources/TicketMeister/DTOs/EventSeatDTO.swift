import Vapor

struct EventSeatDTO: Codable, Content {

  let id: UUID
  let number: Int
  let status: SeatStatus
  let price: Decimal
}
