//
//  CreateUser.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("users")
            .id()
            .field("circle_id", .uuid, .required, .references("circles", "id"))
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("username", .string, .required)
            .field("created_at", .datetime, .required)
            .field("last_modified", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
