import Vapor

struct Booking: Codable {

  let row: String
  let col: Int
  let state: BookingState
}
