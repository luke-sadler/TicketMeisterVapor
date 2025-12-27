import Vapor

struct SeatRequest: Codable {
  let row: String
  let col: Int
}
