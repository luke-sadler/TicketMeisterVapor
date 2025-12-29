import Fluent
import Vapor

struct VenueController: RouteCollection {

    func boot(routes: any RoutesBuilder) throws {

        routes.get("venues", use: allVenues)

        let venues = routes.grouped("venue")
        venues.get(":id", "events", use: venueEvents)
        venues.get(":id", use: venue)
    }

    @Sendable
    func allVenues(req: Request) async throws -> [VenueDTO] {
        try await VenueQueries.getAll(req.db).map { $0.toLiteDto() }
    }

    @Sendable
    func venue(req: Request) async throws -> VenueDTO {
        let id: UUID = try req.requiredId()

        guard let venue = try await VenueQueries.getFull(id: id, req.db) else {
            throw Abort(.notFound)
        }

        return venue.toDto()
    }

    @Sendable
    func venueEvents(req: Request) async throws -> [Event] {
        let id: UUID = try req.requiredId()

        return try await EventQueries.eventsAtVenue(id, on: req.db)
    }

}
