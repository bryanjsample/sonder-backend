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
            .field("value", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .unique(on: "value")
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("access_tokens").delete()
    }

}
