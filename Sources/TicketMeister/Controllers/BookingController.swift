import Fluent
import Vapor

enum BookingError: Error {
  case reservationAlreadyExists

  var descriptor: String {
    switch self {
    case .reservationAlreadyExists:
      "A reservation already exists for this seat"
    }
  }
}

struct BookingController: RouteCollection {

  func boot(routes: any RoutesBuilder) throws {
    routes.get("reservations", use: allReservations)

    routes.group(
      "reservation",
      configure: { route in
        route.post(use: makeReservation)
      })
  }

  @Sendable
  func allReservations(req: Request) async throws -> [SeatingReservationDTO] {
    try await SeatingReservationsQueries.getAll(req.db).map { $0.toDto() }
  }

  @Sendable
  func makeReservation(req: Request) async throws -> SeatingReservationDTO {

    guard let reservationReq = try? req.content.decode(MakeReservationDTO.self) else {
      throw Abort(.badRequest)
    }

    if try await SeatingReservationsQueries.seatingReservationsAlreadyExists(
      seat: reservationReq.seat,
      event: reservationReq.event,
      on: req.db)
    {
      throw Abort(.conflict, reason: BookingError.reservationAlreadyExists.descriptor)
    }

    //TODO: check booked tickets

    let reservation = SeatingReservation(
      event: reservationReq.event,
      seat: reservationReq.seat)
    try await reservation.save(on: req.db)

    let refreshed = try await SeatingReservationsQueries.fullGet(
      id: reservation.requireID(),
      on: req.db)

    return refreshed.toDto()
  }

}
