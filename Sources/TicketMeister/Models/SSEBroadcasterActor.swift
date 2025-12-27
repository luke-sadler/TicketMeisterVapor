import Vapor

actor SSEBroadcaster {
  private var continuations: [UUID: AsyncStream<String>.Continuation] = [:]

  func addClient(id: UUID, continuation: AsyncStream<String>.Continuation) {
    continuations[id] = continuation
  }

  func removeClient(id: UUID) {
    continuations.removeValue(forKey: id)
  }

  func broadcast(event: SSEEvent) {
    for cont in continuations.values {
      cont.yield(event.encode())
    }
  }

  func report() -> String {
    "there are \(continuations.count) continuations"
  }
}

let broadcaster = SSEBroadcaster()
