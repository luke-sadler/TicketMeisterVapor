import Fluent
import Vapor

struct EventController: RouteCollection {

  func boot(routes: any RoutesBuilder) throws {

    routes.get("events", use: allEvents)

    let event = routes.grouped("event")
    event.get(":id", use: getEvent)
  }

  @Sendable
  func allEvents(req: Request) async throws -> [EventDTO] {
    try await EventQueries.getAll(req.db).map { $0.toDto() }
  }

  @Sendable
  func getEvent(req: Request) async throws -> EventDTO {
    let id: UUID = try req.requiredId()

    guard let event = try await Event.get(id, on: req.db) else {
      throw Abort(.notFound)
    }

    return event.toDto()
  }
}
