//
//  CreatePost.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent

struct CreatePost: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("posts")
            .id()
            .field("circle_id", .uuid, .required, .references("circles", "id"))
            .field("author_id", .uuid, .required, .references("users", "id"))
            .field("content", .string, .required)
            .field("created_at", .datetime)
            .field("last_modified", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("posts").delete()
    }
}
