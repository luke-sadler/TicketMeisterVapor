import Fluent
import Vapor

func routes(_ app: Application) throws {

    // app.post("meh") { req async -> String in

    //     await broadcaster.broadcast("\(req.body)")
    //     await print(broadcaster.report())
    //     return "done"
    // }

    app.get("events", "seats") { req async throws -> Response in
        let id = UUID()
        print("adding \(id.uuidString) to clients")
        let stream = AsyncStream<String> { continuation in
            Task {
                // Actor method is async, so we must await
                await broadcaster.addClient(id: id, continuation: continuation)

                continuation.onTermination = { _ in
                    Task {
                        print("removing \(id.uuidString) from clients")
                        await broadcaster.removeClient(id: id)
                    }
                }
            }
        }

        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/event-stream")
        headers.add(name: .cacheControl, value: "no-cache")
        headers.add(name: .connection, value: "keep-alive")

        return Response(
            status: .ok,
            headers: headers,
            body: .init(stream: { writer in
                Task(priority: .background) {
                    do {
                        for await message in stream {
                            var buffer = ByteBufferAllocator().buffer(capacity: message.utf8.count)
                            buffer.writeString(message)
                            try await writer.write(.buffer(buffer)).get()
                        }

                        // Stream ended normally
                        try await writer.write(.end).get()

                    } catch {
                        // Client disconnected or write failed
                        try await writer.write(.error(error)).get()
                    }
                }
            })
        )
    }

    try app.register(collection: VenueController())
    try app.register(collection: EventController())
    try app.register(collection: BookingController())
}
