//
//  CommentTests.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/17/25.
//

@testable import SonderBackend
import VaporTesting
import Testing
import Fluent

@Suite("Comment Tests", .serialized)
struct CommentTests {
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
    
    
}
