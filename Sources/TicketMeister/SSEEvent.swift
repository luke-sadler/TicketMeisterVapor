import Vapor

struct SSEEvent {
  var event: String = "seat_status_change"
  let data: SeatDTO

  func encode() -> String {
    """
    event: \(event)
    data: \(data.dump())

    """
  }
}
