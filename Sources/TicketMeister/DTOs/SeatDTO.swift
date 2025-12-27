import Vapor

struct SeatDTO: Codable, Content {

  let row: String
  let col: Int
  let status: SeatStatus

  func dump() -> String {
    """
    {"row": "\(row)", "col": \(col), "status": "\(status.rawValue)"}
    """
  }
}
