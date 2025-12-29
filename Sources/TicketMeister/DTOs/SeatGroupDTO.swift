import Vapor

struct SeatGroupDTO: Codable, Content {
  let id: UUID?
  let name: String
  let position: Int
  let priceGroup: PriceGroup

}
