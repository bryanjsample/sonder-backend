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
            .field("email", .string, .required)
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("username", .string, .required)
            .field("picture_url", .string, .required)
            .field("created_at", .datetime)
            .field("last_modified", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("users").delete()
    }
}
