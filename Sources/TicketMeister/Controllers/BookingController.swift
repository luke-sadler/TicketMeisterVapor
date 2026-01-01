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

    return refreshed.toDto()
  }

  @Sendable
  func buyTicket(req: Request) async throws -> TicketDTO {
    guard let purchase = try? req.content.decode(PurchaseTicketDTO.self) else {
      try thrower()
    }

    guard
      let reservation = try? await SeatingReservationsQueries.fullGet(
        id: purchase.reservation,
        on: req.db)
    else {
      try thrower(.reservationNotFound)
    }

    guard let expires = reservation.expires, expires > Date() else {
      try thrower(.reservationExpired)
    }

    guard reservation.user.id == purchase.user else {
      try thrower(.reservationForAnotherUser)
    }

    let ticket = Ticket(reservation: reservation)

    if try await TicketQueries.ticketAlreadySold(
      reservation.seat.requireID(),
      reservation.event.requireID(),
      on: req.db)
    {
      try thrower(.seatAlreadySold)
    }

    try await ticket.save(on: req.db)
    let newTicket = try await TicketQueries.getFull(ticket.requireID(), on: req.db)

    try await reservation.delete(on: req.db)

    return newTicket.toDto()

  }

  @Sendable
  func cancelTicket(_ req: Request) async throws -> Response {
    let ticketId = try req.requiredId()

    try await Ticket.find(ticketId, on: req.db)?.delete(on: req.db)
    return Response(status: .accepted)
  }

}
