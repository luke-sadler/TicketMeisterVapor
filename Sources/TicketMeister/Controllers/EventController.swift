import Fluent
import Vapor

struct EventController: RouteCollection {

  func boot(routes: any RoutesBuilder) throws {

    routes.get("events", use: allEvents)

    routes.group("event") { route in
      route.get(":id", use: getEvent)
      route.get([":id", "seating"], use: getEventSeating)
      route.get([":id", "stream"], use: addSeatStream)
    }
  }

  @Sendable
  func allEvents(req: Request) async throws -> [EventDTO] {
    try await EventQueries.getEvents(on: req.db).map { $0.toDto() }
  }

  @Sendable
  func getEvent(req: Request) async throws -> EventDTO {
    let id: UUID = try req.requiredId()

    guard let event = try await EventQueries.getEvent(id, on: req.db) else {
      throw Abort(.notFound)
    }

    return event.toDto()
  }

  @Sendable
  func getEventSeating(_ req: Request) async throws -> EventSeatingMapDTO {
    let eventId: UUID = try req.requiredId()

    // get the event
    guard let event = try await EventQueries.getEvent(eventId, on: req.db) else {
      throw Abort(.notFound)
    }

    let venueId: UUID = event.$venue.id

    // get all the UUIDs for the seats that are sold for this event
    let soldSeatIds: [UUID] = try await TicketQueries.getTicketSeatsForEvent(
      eventId,
      on: req.db)

    // get all the UUIDs for the seats that are reserved for this event
    let reservedSeatIds: [UUID] = try await SeatingReservationsQueries.getReservationSeatsForEvent(
      eventId,
      on: req.db)

    let sold: Set<UUID> = Set(soldSeatIds)
    let reserved: Set<UUID> = Set(reservedSeatIds)

    func availability(for seatID: UUID) -> SeatStatus {
      if sold.contains(seatID) { return .sold }
      if reserved.contains(seatID) { return .reserved }
      return .available
    }

    // All seating groups at this venue
    let groups: [SeatGroup] = try await SeatGroupQueries.getSeatGroupsAtVenue(venueId, on: req.db)

    let sectionDTOs: [EventSeatSectionDTO] = groups.map { section in

      return EventSeatSectionDTO(
        id: section.id!,
        name: section.name,
        position: section.position,
        seats: section.seats.map { seat in
          EventSeatDTO(
            id: seat.id!,
            number: seat.number,
            status: availability(for: seat.id!),
            price: section.priceGroup.value
          )
        }
      )
    }

    return EventSeatingMapDTO(
      eventId: eventId,
      venueId: venueId,
      sections: sectionDTOs.sorted { $0.position < $1.position }
    )
  }

  @Sendable
  func addSeatStream(_ req: Request) async throws -> Response {

    let eventId = try req.requiredId()

    let id = UUID()
    print("adding \(id.uuidString) to clients")
    let stream = AsyncStream<String> { continuation in
      Task {
        // Actor method is async, so we must await
        await broadcaster.addClient(id: id, event: eventId, continuation: continuation)

        continuation.onTermination = { _ in
          Task {
            print("removing \(id.uuidString) from clients")
            await broadcaster.removeClient(id: id)
          }
        }
      }
    }

    var headers = HTTPHeaders()
    headers.add(name: .contentType, value: "text/event-stream")
    headers.add(name: .cacheControl, value: "no-cache")
    headers.add(name: .connection, value: "keep-alive")

    return Response(
      status: .ok,
      headers: headers,
      body: .init(stream: { writer in
        Task(priority: .background) {
          do {
            for await message in stream {
              var buffer = ByteBufferAllocator().buffer(capacity: message.utf8.count)
              buffer.writeString(message)
              try await writer.write(.buffer(buffer)).get()
            }

            // Stream ended normally
            try await writer.write(.end).get()

          } catch {
            // Client disconnected or write failed
            try await writer.write(.error(error)).get()
          }
        }
      })
    )
  }
}
