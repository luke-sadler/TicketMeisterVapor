import Vapor

struct EventSeatingMapDTO: Content {
  let eventID: UUID
  let venueID: UUID
  let sections: [EventSeatSectionDTO]
}
