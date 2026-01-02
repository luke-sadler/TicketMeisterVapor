import Vapor

struct SSEEvent {
  let data: SeatUpdatEventDTO

  private var encoded: String {
    let encoded = try! JSONEncoder().encode(data)
    return String(data: encoded, encoding: .utf8)!
  }

  func encode() -> String {

    """
    \(encoded)

    """
  }
}
