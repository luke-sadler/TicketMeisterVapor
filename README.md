# TicketMeister

A toy ticket booking application.

The purpose of this project is (currently) to serve as a PoC to play with server side events. It's not really something I've played around with before, so I figured why not make a simple ticket booking app?  

If you want to run this, you'll want to be running a Postgres server (probably in Docker) and either change the config values in `configure.swift` or set the appropriate values in a `.env.development` file in the project root.

Currently no mock data is injected and in my own instance, I've just manually thrown some data in via DBeaver. The data structure is something along the lines of (simplified):

```
Venue
  name

Event
  venue
  name
  start time

Seat
 number
 seat group

Seat Group (row, VIP box, whatever..)
 price group
 venue
 name

Price Group
 name
 value

Reservation
 user
 seat
 event

Ticket
 user
 seat
 event
```

There are currently some endpoints for basic, unauthenticated functionality.

---
### Events  

List all events  
`GET /events`

Get event info  
`GET /event/:id`  

Start streaming seat updates. SSE updates for reservation and tickets for seat changes.  
`GET /event/:id/stream`

--- 
### Venues

Get all venues  
`GET /venues`  

Get venue  
`GET /venue/:id`  

---
### Events

Get all events  
`GET /events`  

Get event details  
`GET /event/:id`  

---
### Reservations

Reserve a seat during checkout.
Use `MakeReservationDTO` in body.  
`POST /reservation`

---
### Tickets

Book a ticket, passing in `PurchaseTicketDTO` in body  
`POST /ticket`  

Cancels ticket  
`POST /ticket/:id/cancel`

