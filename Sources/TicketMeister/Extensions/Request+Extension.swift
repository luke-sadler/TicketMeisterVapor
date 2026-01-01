import Vapor

extension Request {

  /// Extracts the :id from the request parameters
  func requiredId() throws -> UUID {
    guard let id: UUID = self.parameters.get("id") else {
      throw Abort(.badRequest, reason: "UUID is invalid")
    }
    return id
  }

}
