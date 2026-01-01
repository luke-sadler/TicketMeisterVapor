import Vapor

struct UserDTO: Codable, Content {

  let id: UUID?
  let username: String
}
