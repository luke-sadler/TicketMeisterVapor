import Vapor

struct Seat: Codable {

  let row: String
  let col: Int
  var status: SeatStatus

  mutating func updateStatus(_ status: SeatStatus) {
    self.status = status
  }

  func toDto() -> SeatDTO {
    .init(
      row: row,
      col: col,
      status: status)
  }
}

extension Seat {

  static func ~= (lhs: Seat, rhs: SeatRequest) -> Bool {
    lhs.row == rhs.row && lhs.col == rhs.col
  }
}
