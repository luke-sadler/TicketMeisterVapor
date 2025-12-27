import Vapor

enum SeatStatus: String, Codable {
  case available
  case onHold
  case sold
}
