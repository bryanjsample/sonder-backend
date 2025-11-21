//
//  CalendarEventTests.swift
//  SonderBackend
//
//  Created by Test Generator on 11/20/25.
//

@testable import SonderBackend
import VaporTesting
import Testing
import Fluent

@Suite("Calendar Event Endpoint Tests", .serialized)
struct CalendarEventTests {
    
    let helper = TestHelpers()
    
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }


    // MARK: - Tests per endpoint

    @Test("POST /circles/:circleID/events/user/:userID - Create Event")
    func testCreateEvent() async throws {
        try await withApp { app in
            let title = "Game Night \(UUID().uuidString.prefix(6))"

            _ = try await helper.createEvent(app: app, title: title)
        }
    }

    @Test("GET /circles/:circleID/events - Retrieve Circle Events")
    func testRetrieveCircleEvents() async throws {
        try await withApp { app in
            let title = "List Event \(UUID().uuidString.prefix(6))"
            
            let evt = try await helper.createEvent(app: app, title: title)

            try await app.test(.GET, "\(helper.circlesRoute)/\(evt.$circle.id.uuidString)/\(helper.eventsSegment)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("GET /circles/:circleID/events/user/:userID - Retrieve User Events")
    func testRetrieveUserEvents() async throws {
        try await withApp { app in
            let title = "User Event \(UUID().uuidString.prefix(6))"
            let evt = try await helper.createEvent(app: app, title: title)

            try await app.test(.GET, "\(helper.circlesRoute)/\(evt.$circle.id.uuidString)/\(helper.eventsSegment)/user/\(evt.$host.id.uuidString)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("GET /circles/:circleID/events/:eventID - Retrieve Event")
    func testRetrieveEvent() async throws {
        try await withApp { app in
            let title = "Get Event \(UUID().uuidString.prefix(6))"
            let evt = try await helper.createEvent(app: app, title: title)

            try await app.test(.GET, "\(helper.circlesRoute)/\(evt.$circle.id.uuidString)/\(helper.eventsSegment)/\(evt.id!.uuidString)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("PATCH /circles/:circleID/events/:eventID - Edit Event")
    func testEditEvent() async throws {
        try await withApp { app in
            let title = "Original Event \(UUID().uuidString.prefix(6))"
            let evt = try await helper.createEvent(app: app, title: title)

            // Fetch DTO first to preserve required fields (host/circle)
            var dto = try await app.getResponse(
                method: .GET,
                path: "\(helper.circlesRoute)/\(evt.$circle.id.uuidString)/\(helper.eventsSegment)/\(evt.id!.uuidString)",
                as: CalendarEventDTO.self
            )
            dto.title = dto.title + " (Edited)"
            dto.description = "Updated description"
            // Keep start/end as-is or adjust as desired

            try await app.test(.PATCH, "\(helper.circlesRoute)/\(evt.$circle.id.uuidString)/\(helper.eventsSegment)/\(evt.id!.uuidString)", beforeRequest: { req in
                try req.content.encode(dto)
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("DELETE /circles/:circleID/events/:eventID - Remove Event")
    func testRemoveEvent() async throws {
        try await withApp { app in
            let title = "Delete Event \(UUID().uuidString.prefix(6))"
            let evt = try await helper.createEvent(app: app, title: title)

            try await app.test(.DELETE, "\(helper.circlesRoute)/\(evt.$circle.id.uuidString)/\(helper.eventsSegment)/\(evt.id!.uuidString)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }
}

private extension Application {
    func getResponse<T: Decodable>(method: HTTPMethod, path: String, as type: T.Type) async throws -> T {
        var decoded: T!
        try await self.test(method, path, afterResponse: { res in
            #expect(res.status == .ok)
            decoded = try res.content.decode(T.self)
        })
        return decoded
    }
}

