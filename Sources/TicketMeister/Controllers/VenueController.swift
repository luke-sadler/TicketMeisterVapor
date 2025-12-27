import Fluent
import Vapor

struct VenueController: RouteCollection {

    let venue = Venue(name: "Stadium1", rows: 3, cols: 3)

    func boot(routes: any RoutesBuilder) throws {
        let bookings = routes.grouped("venue")

        bookings.get("status", use: self.index)
        bookings.on(.POST, ["reserve"], use: self.holdSeat)
        bookings.on(.POST, ["release"], use: self.releaseSeat)
    }

    @Sendable
    func index(req: Request) async throws -> VenueDTO {
        await venue.toDto()
    }

    @Sendable
    func holdSeat(req: Request) async throws -> Response {
        let request = try req.content.decode(SeatRequest.self)

        do {
            let seat: Seat = try await venue.holdSeat(request: request)
            await broadcaster.broadcast(event: .init(data: seat.toDto()))

        } catch let error {
            return .init(badRequest: error)
        }

        return Response(status: .accepted)
    }

    @Sendable
    func releaseSeat(req: Request) async throws -> Response {
        let request = try req.content.decode(SeatRequest.self)

        do {
            let seat: Seat = try await venue.releaseSeat(request: request)
            await broadcaster.broadcast(event: .init(data: seat.toDto()))

        } catch let error {
            return .init(badRequest: error)
        }

        return Response(status: .accepted)
    }
}
