import Vapor

enum ChangeError: Error {
  case unableToFind
  case alreadyOnHold
  case alreadySold
}

actor Venue {
  var name: String
  var seats: [Seat]

  init(name: String, rows: Int, cols: Int) {

    precondition(rows > 0, "rows must be greater than 0")

    func rowLabel(_ number: Int) -> String {
      var n = number
      var result = ""

      while n > 0 {
        n -= 1
        result = String(UnicodeScalar(65 + n % 26)!) + result
        n /= 26
      }

      return result
    }

    self.name = name
    self.seats = (1...rows).map { row in

      return (1...cols).map { col in

        return Seat(row: rowLabel(row), col: col, status: .available)
      }
    }
    .reduce([], +)

  }

  private func updateSeat(_ idx: Array<Int>.Index, _ new: Seat) {
    seats.remove(at: idx)
    seats.insert(new, at: idx)
  }

  func releaseSeat(request: SeatRequest) throws -> Seat {
    if let idx = self.seats.firstIndex(where: { $0 ~= request }) {
      let seat = seats[idx]
      let new = Seat(row: request.row, col: request.col, status: .available)
      updateSeat(idx, new)
      return new
    }

    throw ChangeError.unableToFind
  }

  func holdSeat(request: SeatRequest) throws -> Seat {
    if let idx = self.seats.firstIndex(where: { $0 ~= request }) {
      let seat = seats[idx]
      switch seat.status {
      case .available:
        let new = Seat(row: request.row, col: request.col, status: .onHold)
        updateSeat(idx, new)
        return new
      case .onHold: throw ChangeError.alreadyOnHold
      case .sold: throw ChangeError.alreadySold
      }
    }
    throw ChangeError.unableToFind
  }

  func toDto() -> VenueDTO {
    .init(
      name: name,
      seats: seats.map { $0.toDto() })
  }
}
