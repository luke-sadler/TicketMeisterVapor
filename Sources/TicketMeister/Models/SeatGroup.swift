import Fluent
import Vapor

final class SeatGroup: Model, Authenticatable, Content, @unchecked Sendable {
  static let schema = "seat_section"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "name")
  var name: String

  @Field(key: "position")
  var position: Int

  @Parent(key: "price_group")
  var priceGroup: PriceGroup

  @Parent(key: "venue")
  var venue: Venue

  @Children(for: \.$section)
  var seats: [Seat]

  init() {}

  init(
    id: UUID?,
    name: String,
    position: Int,
    priceGroup: PriceGroup
  ) {
    self.id = id
    self.name = name
    self.position = position
    self.priceGroup = priceGroup
  }

  func toDto() -> SeatGroupDTO {
    .init(
      id: id,
      name: name,
      position: position,
      priceGroup: priceGroup)
  }
}
