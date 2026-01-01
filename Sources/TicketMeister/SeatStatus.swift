import Vapor

enum SeatStatus: String, Codable {
  case available
  case reserved
  case sold
}
