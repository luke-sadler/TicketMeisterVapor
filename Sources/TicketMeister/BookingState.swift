import Vapor

enum BookingState: String, Codable {
  case hold, purchase, abort
}
