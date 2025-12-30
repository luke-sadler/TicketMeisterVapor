import Vapor

struct SeatDTO: Codable, Content {

  let section: SeatGroupDTO
  let number: Int
}
