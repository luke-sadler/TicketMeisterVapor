import Fluent
import Vapor

extension Optional {
  func unwrap(or error: any Error) throws -> Wrapped {
    guard let value: Wrapped = self else { throw error }
    return value
  }
}
