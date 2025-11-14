//
//  CreateComment.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent

struct CreateComment: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("comments")
            .id()
            .field("post_id", .uuid, .required, .references("posts", "id"))
            .field("author_id", .uuid, .required, .references("users", "id"))
            .field("content", .string, .required)
            .field("created_at", .datetime, .required)
            .field("last_modified", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("comments").delete()
    }
}
