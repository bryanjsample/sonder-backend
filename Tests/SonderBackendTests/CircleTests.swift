//
//  CircleTests.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/17/25.
//

@testable import SonderBackend
import VaporTesting
import Testing
import Fluent

@Suite("Circle Tests", .serialized)
struct CircleTests {
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
    
    // Sample DTOs for creating circles (no edge-case validation here)
    let circleDTOs: [CircleDTO] = [
        CircleDTO(name: "iOS Devs", description: "A circle for iOS developers", pictureUrl: nil),
        CircleDTO(name: "Vapor Backend", description: "Server-side Swift enthusiasts", pictureUrl: "https://cdn.example.com/circles/vapor.png"),
        CircleDTO(name: "Data Science", description: "Discuss ML and data engineering", pictureUrl: nil),
        CircleDTO(name: "Design Systems", description: "UI/UX and design tokens", pictureUrl: "https://images.site.net/circles/design.webp"),
        CircleDTO(name: "Open Source", description: "Contributors welcome", pictureUrl: nil),
    ]
    
    // Sample models for GET/PATCH/DELETE flows
    let circles: [Circle] = [
        Circle(name: "SwiftUI", description: "All things SwiftUI", pictureUrl: nil),
        Circle(name: "Kotlin Buddies", description: "Friendly neighbors across the aisle", pictureUrl: nil),
        Circle(name: "Rustaceans", description: "Rust learning circle", pictureUrl: "https://static.domain.io/circles/rustaceans.png"),
        Circle(name: "Databases", description: "Postgres, SQLite, and more", pictureUrl: nil),
        Circle(name: "Game Dev", description: "Graphics and gameplay", pictureUrl: "https://cdn.example.com/circles/gamedev.jpg"),
    ]
    
    @Test("Test /circles POST")
    func createCircle() async throws {
        try await withApp { app in
            for dto in circleDTOs {
                try await app.testing().test(.POST, "circles", beforeRequest: { req in
                    try req.content.encode(dto)                }, afterResponse: { res in
                    #expect(res.status == .created)
                })
            }
        }
    }
    
    @Test("Test /circles/:circleID GET")
    func getCircle() async throws {
        try await withApp { app in
            for circle in circles {
                try await circle.save(on: app.db)
                let circleID = circle.id?.uuidString ?? "id_missing"
                try await app.testing().test(.GET, "circles/\(circleID)", afterResponse: { res in
                    #expect(res.status == .ok)
                })
            }
        }
    }
    
    @Test("Test /circles/:circleID PATCH")
    func patchCircle() async throws {
        try await withApp { app in
            for circle in circles {
                try await circle.save(on: app.db)
                let circleID = circle.id?.uuidString ?? "id_missing"
                var dto = CircleDTO(from: circle)
                dto.description = "PATCHED DESCRIPTION"
                try await app.testing().test(.PATCH, "circles/\(circleID)", beforeRequest: { req in
                    try req.content.encode(dto)
                }, afterResponse: { res in
                    #expect(res.status == .ok)
                })
            }
        }
    }
    
    @Test("Test /circles/:circleID DELETE")
    func deleteCircle() async throws {
        try await withApp { app in
            for circle in circles {
                try await circle.save(on: app.db)
                let circleID = circle.id?.uuidString ?? "id_missing"
                let dto = CircleDTO(from: circle)
                try await app.testing().test(.DELETE, "circles/\(circleID)", beforeRequest: { req in
                    try req.content.encode(dto)
                }, afterResponse: { res in
                    #expect(res.status == .ok)
                })
            }
        }
    }
    
    @Test("Test /circles/:circleID/users GET")
    func getCircleMembers() async throws {
        try await withApp { app in
            let circle = try await Circle.query(on: app.db)
                .filter(\.$name == "TEST CIRCLE")
                .first()
            let circleID = circle?.id?.uuidString ?? "id_missing"
            try await app.testing().test(.GET, "circles/\(circleID)/users", afterResponse: { res in
                #expect(res.status == .ok)
                let data = try res.content.decode([UserDTO].self)
                print("\n\n\(data)\n\n")
            })
        }
    }
    
    @Test("Test /circles/:circleID/feed GET")
    func getCircleFeed() async throws {
        try await withApp { app in
            let circle = try await Circle.query(on: app.db)
                .filter(\.$name == "TEST CIRCLE")
                .first()
            let circleID = circle?.id?.uuidString ?? "id_missing"
            try await app.testing().test(.GET, "circles/\(circleID)/feed", afterResponse: { res in
                #expect(res.status == .ok)
                let data = try res.content.decode(FeedResponseDTO.self)
                print("\n\n\(data)\n\n")
            })
        }
    }
    
}

