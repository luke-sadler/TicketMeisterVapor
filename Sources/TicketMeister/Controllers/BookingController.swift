import Fluent
import Foundation
import Vapor

enum BookingError: Error {
  case reservationAlreadyExists
  case seatAlreadySold
  case reservationExpired
  case reservationForAnotherUser
  case reservationNotFound

  var descriptor: String {
    switch self {
    case .reservationAlreadyExists:
      "A reservation already exists for this seat"
    case .seatAlreadySold:
      "This seat has already been sold"
    case .reservationExpired:
      "This reservation has expired"
    case .reservationForAnotherUser:
      "This reservation belongs to another user"
    case .reservationNotFound:
      "A reservation was not found"
    }
  }
}

struct BookingController: RouteCollection {

  func thrower(_ error: BookingError? = nil) throws -> Never {
    if let error {
      throw Abort(.badRequest, reason: error.descriptor)
    } else {
      throw Abort(.badRequest)
    }
  }

  func boot(routes: any RoutesBuilder) throws {

    routes.get("reservations", use: allReservations)

    routes.group(
      "reservation",
      configure: { route in
        route.post(use: makeReservation)
      })

    routes.group("ticket") { route in
      route.post(use: buyTicket)
      route.post([":id", "cancel"], use: cancelTicket)
    }
  }

  @Sendable
  func allReservations(req: Request) async throws -> [SeatingReservationDTO] {
    try await SeatingReservationsQueries.getAll(req.db).map { $0.toDto() }
  }

  @Sendable
  func makeReservation(req: Request) async throws -> SeatingReservationDTO {

    guard let reservationReq = try? req.content.decode(MakeReservationDTO.self) else {
      try thrower()
    }

    if try await TicketQueries.ticketAlreadySold(
      reservationReq.seat, reservationReq.event, on: req.db)
    {
      try thrower(.seatAlreadySold)
    }

    if try await SeatingReservationsQueries.seatingReservationsAlreadyExists(
      seat: reservationReq.seat,
      event: reservationReq.event,
      on: req.db)
    {
      try thrower(.reservationAlreadyExists)
    }

    // 10 minutes default
    let reservationDuration =
      Environment.get("RESERVATION_DURATION_SECONDS").flatMap(TimeInterval.init(_:)) ?? 600

    let expires = Date().addingTimeInterval(reservationDuration)

    let reservation = SeatingReservation(
      user: reservationReq.user,
      event: reservationReq.event,
      seat: reservationReq.seat,
      expires: expires)
    try await reservation.save(on: req.db)

    let refreshed = try await SeatingReservationsQueries.fullGet(
      id: reservation.requireID(),
      on: req.db)

    Task {
      await broadcaster.broadcast(
        event: .init(
          data:
            .init(
              seatId: reservationReq.seat,
              eventId: reservationReq.event,
              newStatus: .reserved))
      )
    }

    return refreshed.toDto()
  }

  @Sendable
  func buyTicket(req: Request) async throws -> TicketDTO {
    guard let purchase = try? req.content.decode(PurchaseTicketDTO.self) else {
      try thrower()
    }

    // Retrieve the reservation
    guard
      let reservation: SeatingReservation = try? await SeatingReservationsQueries.fullGet(
        id: purchase.reservation,
        on: req.db)
    else {
      try thrower(.reservationNotFound)
    }

    // Check the reservation is valid
    guard let expires: Date = reservation.expires, expires > Date() else {
      try thrower(.reservationExpired)
    }

    // Check the reservation is for the given user
    guard reservation.user.id == purchase.user else {
      try thrower(.reservationForAnotherUser)
    }

    let ticket = Ticket(reservation: reservation)

    do {
      // try to write to the db
      try await ticket.save(on: req.db)
    } catch let error as any DatabaseError where error.isConstraintFailure {
      // There is a failure on the UNIQUE (seatId, eventId) contraint
      try thrower(.seatAlreadySold)
    } catch let error {
      throw error
    }

    // fetch the ticket back
    let newTicket = try await TicketQueries.getFull(ticket.requireID(), on: req.db)

    // remove the old reservation
    try await reservation.delete(on: req.db)

    Task {
      try await broadcaster.broadcast(
        event:
          .init(
            data: .init(
              seatId: reservation.seat.requireID(),
              eventId: reservation.event.requireID(),
              newStatus: .sold))
      )
    }

    return newTicket.toDto()
  }

  @Sendable
  func cancelTicket(_ req: Request) async throws -> Response {
    let ticketId = try req.requiredId()
    guard let ticket = try await Ticket.find(ticketId, on: req.db) else {
      return Response(status: .notFound)
    }

    try await ticket.delete(on: req.db)

    Task {
      try await broadcaster.broadcast(
        event:
          .init(
            data: .init(
              seatId: ticket.seat.requireID(),
              eventId: ticket.event.requireID(),
              newStatus: .sold))
      )
    }

    return Response(status: .accepted)
  }

}
