import Fluent
import Vapor

final class Seat: Model,
  Authenticatable,
  Content,
  @unchecked Sendable,
  DTORepresentable
{
  static let schema = "seating"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "section")
  var section: SeatGroup

  @Field(key: "number")
  var number: Int

  init() {}

  init(
    id: UUID?,
    section: SeatGroup,
    number: Int
  ) {
    self.id = id
    self.section = section
    self.number = number
  }

  func toDto() -> SeatDTO {
    .init(
      section: section.toDto(),
      number: number)
  }

}
