import Vapor

extension Response.Body {
  init(error: any Error) {
    self.init(string: "{\"error\": \"\(error)\"}")
  }
}

extension Response {
  convenience init(badRequest error: any Error) {
    self.init(status: .badRequest, body: .init(error: error))
  }
}
