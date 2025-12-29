import Fluent

enum QueryError: Error {
  case notFound
  case wrongDatabase
  case other(any Error)
}

protocol DatabaseQuery {
  associatedtype T: Model

  static func getAll(_ db: any Database) async throws -> [T]
}

extension DatabaseQuery {
  static func getAll(_ db: any Database) async throws -> [T] {
    try await T.query(on: db).all()
  }

}
