import Vapor

struct SeatDTO: Codable, Content {

  let section: UUID
  let number: Int
  let status: SeatStatus

  func dump() -> String {
    """
    {"section": "\(section)", "number": \(number), "status": "\(status.rawValue)"}
    """
  }
}
