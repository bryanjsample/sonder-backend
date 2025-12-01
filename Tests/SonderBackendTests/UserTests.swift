//
//  UserTests.swift
//  SonderBackend
//
//  Created by Test Generator on 11/20/25.
//

import Fluent
import Testing
import VaporTesting

@testable import SonderBackend

@Suite("User Endpoint Tests", .serialized)
struct UserTests {

    let helper = TestHelpers()

    private func withApp(_ test: (Application) async throws -> Void)
        async throws
    {
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

    @Test("POST /users - Create User")
    func testCreateUser() async throws {
        try await withApp { app in
            let email = "user_\(UUID().uuidString)@example.com"
            _ = try await helper.createUser(app: app, email: email)
        }
    }

    @Test("GET /users/:userID - Retrieve User")
    func testRetrieveUser() async throws {
        try await withApp { app in
            let email = "user_\(UUID().uuidString)@example.com"
            let user = try await helper.createUser(app: app, email: email)

            try await app.test(
                .GET,
                "\(helper.usersRoute)/\(try #require(user.id).uuidString)",
                afterResponse: { res in
                    #expect(res.status == .ok)
                    // Optionally decode to ensure DTO shape is correct:
                    _ = try res.content.decode(UserDTO.self)
                }
            )
        }
    }

    @Test("PATCH /users/:userID - Edit User")
    func testEditUser() async throws {
        try await withApp { app in
            let email = "user_\(UUID().uuidString)@example.com"
            let user = try await helper.createUser(app: app, email: email)
            let userID = try #require(user.id)

            // Fetch current DTO
            var dto = try await app.getResponse(
                method: .GET,
                path: "\(helper.usersRoute)/\(userID.uuidString)",
                as: UserDTO.self
            )
            // Modify some fields with valid data
            dto.firstName = "UpdatedFirst"
            dto.lastName = "UpdatedLast"
            dto.username = "updated_\(UUID().uuidString.prefix(6))"
            dto.pictureUrl =
                "https://cdn.example.com/avatars/\(UUID().uuidString).png"

            try await app.test(
                .PATCH,
                "\(helper.usersRoute)/\(userID.uuidString)",
                beforeRequest: { req in
                    try req.content.encode(dto)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                    // Optionally decode and verify fields round-trip:
                    let updated = try res.content.decode(UserDTO.self)
                    #expect(
                        updated.firstName
                            == SonderBackend.InputSanitizer.sanitizeName(
                                dto.firstName
                            )
                    )
                    #expect(
                        updated.lastName
                            == SonderBackend.InputSanitizer.sanitizeName(
                                dto.lastName
                            )
                    )
                }
            )
        }
    }

    @Test("DELETE /users/:userID - Remove User")
    func testRemoveUser() async throws {
        try await withApp { app in
            let email = "user_\(UUID().uuidString)@example.com"
            let user = try await helper.createUser(app: app, email: email)

            try await app.test(
                .DELETE,
                "\(helper.usersRoute)/\(try #require(user.id).uuidString)",
                afterResponse: { res in
                    #expect(res.status == .ok)
                }
            )
        }
    }
}

extension Application {
    // Helper to GET and decode a DTO in tests
    fileprivate func getResponse<T: Decodable>(
        method: HTTPMethod,
        path: String,
        as type: T.Type
    ) async throws -> T {
        var decoded: T!
        try await self.test(
            method,
            path,
            afterResponse: { res in
                #expect(res.status == .ok)
                decoded = try res.content.decode(T.self)
            }
        )
        return decoded
    }
}
