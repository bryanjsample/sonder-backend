//
//  CircleTests.swift
//  SonderBackend
//
//  Created by Test Generator on 11/20/25.
//

@testable import SonderBackend
import VaporTesting
import Testing
import Fluent

@Suite("Circle Endpoint Tests", .serialized)
struct CircleTests {
    
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

    @Test("POST /circles - Create Circle")
    func testCreateCircle() async throws {
        try await withApp { app in
            let name = "Circle\(UUID().uuidString.prefix(6))"
            _ = try await helper.createCircle(app: app, name: name)
        }
    }

    @Test("GET /circles/:circleID - Retrieve Circle")
    func testRetrieveCircle() async throws {
        try await withApp { app in
            let name = "Circle\(UUID().uuidString.prefix(6))"
            let circle = try await helper.createCircle(app: app, name: name)

            try await app.test(.GET, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("PATCH /circles/:circleID - Edit Circle")
    func testEditCircle() async throws {
        try await withApp { app in
            let name = "Circle\(UUID().uuidString.prefix(6))"
            let circle = try await helper.createCircle(app: app, name: name)

            // Fetch DTO, modify, PATCH
            var dto = try await app.getResponse(
                method: .GET,
                path: "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)",
                as: CircleDTO.self
            )
            dto.description = (dto.description) + " (edited)"

            try await app.test(.PATCH, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)", beforeRequest: { req in
                try req.content.encode(dto)
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("DELETE /circles/:circleID - Remove Circle")
    func testRemoveCircle() async throws {
        try await withApp { app in
            let name = "Circle\(UUID().uuidString.prefix(6))"
            let circle = try await helper.createCircle(app: app, name: name)

            try await app.test(.DELETE, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("GET /circles/:circleID/users - Retrieve Circle Users")
    func testRetrieveCircleUsers() async throws {
        try await withApp { app in
            let name = "Circle\(UUID().uuidString.prefix(6))"
            let circle = try await helper.createCircle(app: app, name: name)

            try await app.test(.GET, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/users", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("GET /circles/:circleID/feed - Retrieve Circle Feed")
    func testRetrieveCircleFeed() async throws {
        try await withApp { app in
            let name = "Circle\(UUID().uuidString.prefix(6))"
            let circle = try await helper.createCircle(app: app, name: name)

            // Seed feed with one post and one event
            let email = "feedhost_\(UUID().uuidString)@example.com"
            let user = try await helper.createUser(app: app, email: email)
            _ = try await helper.createPost(app: app, circleID: try #require(circle.id), authorID: try #require(user.id), content: "Hello World")
            _ = try await helper.createEvent(app: app, title: "Meetup \(UUID().uuidString.prefix(5))")

            try await app.test(.GET, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/feed", afterResponse: { res in
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
