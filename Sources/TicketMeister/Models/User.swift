import Fluent
import Vapor

final class User: Model,
  Authenticatable,
  Content,
  @unchecked Sendable,
  DTORepresentable
{
  static let schema = "users"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "username")
  var username: String

  func toDto() -> UserDTO {
    .init(
      id: id,
      username: username)
  }
}
