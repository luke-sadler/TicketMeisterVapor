import Fluent
import Vapor

final class PriceGroup: Model,
  Authenticatable,
  Content,
  @unchecked Sendable,
  DTORepresentable
{
  static let schema = "price_group"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "value")
  var value: Decimal

  @Field(key: "title")
  var title: String

  init() {}

  init(
    id: UUID?,
    value: Decimal,
    title: String
  ) {
    self.id = id
    self.value = value
    self.title = title
  }

  func toDto() -> PriceGroupDTO {
    .init(
      id: id,
      title: title,
      value: value)
  }
}
