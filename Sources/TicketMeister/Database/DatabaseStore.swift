import Fluent
import Foundation

struct DatabaseStore {
  @discardableResult
  static func create<T: Model>(_ m: T, _ db: any Database) async throws -> T {
    try await m.save(on: db)
    return m
  }

  @discardableResult
  static func update<T: Model>(
    _ obj: T,
    _ db: any Database,
    update: (inout T) -> Void
  ) async throws -> T {

    var mObj = obj
    update(&mObj)
    try await obj.update(on: db)
    return mObj
  }

}
