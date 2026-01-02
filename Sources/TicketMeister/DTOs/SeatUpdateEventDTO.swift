import Vapor

struct SeatUpdatEventDTO: Codable, Content {
  let seatId: UUID
  let eventId: UUID
  let newStatus: SeatStatus
}
