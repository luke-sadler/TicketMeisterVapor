import Vapor

private struct EventContinuation {
  var continuations: [UUID: AsyncStream<String>.Continuation]
}

private class ContinationStore {

  private var events: [UUID: EventContinuation] = [:]  // event: [user:continuations]
  // reverse storage for faster user lookup
  private var userDict: [UUID: UUID] = [:]  // user:event

  func addContinuation(
    user: UUID,
    event: UUID,
    _ continuation: AsyncStream<String>.Continuation
  ) {

    if events[event]?.continuations != nil {
      events[event]?.continuations[user] = continuation
    } else {
      events[event] = .init(continuations: [user: continuation])
    }

    userDict[user] = event
  }

  func removeContinuation(user: UUID) {

    if let event = userDict[user] {
      events[event]?.continuations.removeValue(forKey: user)
      userDict.removeValue(forKey: user)
      print("found and removed user")
    }
  }

  func continuations(for event: UUID) -> EventContinuation? {
    events[event]
  }

}

actor SSEBroadcaster {
  private var continuationStore = ContinationStore()

  func addClient(id: UUID, event: UUID, continuation: AsyncStream<String>.Continuation) {
    continuationStore.addContinuation(user: id, event: event, continuation)
  }

  func removeClient(id: UUID) {
    continuationStore.removeContinuation(user: id)
    print("removing id \(id)")
  }

  func broadcast(event: SSEEvent) {
    let eventId = event.data.eventId
    guard let eventCont = continuationStore.continuations(for: eventId) else {
      return
    }

    for cont in eventCont.continuations {
      cont.value.yield(event.encode())
    }
  }
}

let broadcaster = SSEBroadcaster()
