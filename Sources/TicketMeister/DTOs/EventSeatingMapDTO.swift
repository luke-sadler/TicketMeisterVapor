import Vapor

struct EventSeatingMapDTO: Content {
  let eventId: UUID
  let venueId: UUID
  let sections: [EventSeatSectionDTO]
}
