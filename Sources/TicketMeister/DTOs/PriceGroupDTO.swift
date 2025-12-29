import Vapor

struct PriceGroupDTO: Codable, Content {
  let id: UUID?
  let title: String
  let value: Decimal
}
