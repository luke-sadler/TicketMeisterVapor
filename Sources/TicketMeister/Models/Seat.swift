import Fluent
import Vapor

final class Seat: Model, Authenticatable, Content, @unchecked Sendable {
  static let schema = "seating"

  @ID(key: .id)
  var id: UUID?

  @Parent(key: "section")
  var section: SeatGroup

  @Field(key: "number")
  var number: Int

  @Field(key: "status")
  var status: SeatStatus

  init() {}

  init(
    id: UUID?,
    section: SeatGroup,
    number: Int,
    status: SeatStatus
  ) {
    self.id = id
    self.section = section
    self.number = number
    self.status = status
  }

  // mutating func updateStatus(_ status: SeatStatus) {
  //   self.status = status
  // }

  // func toDto() -> SeatDTO {
  //   .init(
  //     section: section, number: number, status: status
  //     )
  // }
}

// extension Seat {

//   static func ~= (lhs: Seat, rhs: SeatRequest) -> Bool {
//     lhs.section == rhs.section && lhs.number == rhs.number
//   }
// }
