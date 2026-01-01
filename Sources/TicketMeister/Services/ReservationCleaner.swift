import Vapor

/// Removes expired reservations every `RESERVATION_CHECK_INTERVAL` minutes - defaults to 30
/// This just keeps the database clean and doesnt affect the "is already reserved?" functionality.
func setupReservationsClearJob(_ app: Application) {

  var interval: Int64 {
    if let intervalStr: String = Environment.get("RESERVATION_CHECK_INTERVAL"),
      let cast: Int64 = Int64(intervalStr)
    {
      return cast
    } else {
      return 30
    }
  }

  app.logger.info("Reservations cleanup job setup (\(interval) seconds)")

  app.eventLoopGroup.next().scheduleRepeatedTask(
    initialDelay: .seconds(5),
    delay: .minutes(interval)
  ) {
    task in
    // Wrap your async work inside a Task
    Task {
      do {
        let removed = try await SeatingReservationsQueries.removeExpiredReservations(on: app.db)
        if removed > 0 {
          app.logger.info("removed \(removed) expired reservations")
        }
      } catch let error {
        app.logger.error("Reservations clean failed with: \(String(describing: error))")
      }
    }
  }

}
