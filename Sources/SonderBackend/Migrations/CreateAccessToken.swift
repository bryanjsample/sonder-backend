//
//  CreateAccessToken.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/24/25.
//

import Fluent

struct CreateAccessToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("access_tokens")
            .id()
            .field("token", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .field("expires_at", .datetime, .required)
            .field("revoked", .bool, .required)
            .unique(on: "token")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("access_tokens").delete()
    }

}
