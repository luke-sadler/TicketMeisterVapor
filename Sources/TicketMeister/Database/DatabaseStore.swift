import Fluent
import Foundation

struct DatabaseStore {

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
