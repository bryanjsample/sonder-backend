//
//  CreateCircle.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent

struct CreateCircle: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("circles")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("picture_url", .string)
            .field("created_at", .datetime)
            .field("last_modified", .datetime)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("circles").delete()
    }
}
