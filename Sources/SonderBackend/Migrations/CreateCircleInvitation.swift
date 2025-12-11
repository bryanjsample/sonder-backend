//
//  CreateCircleInvitation.swift
//  SonderBackend
//
//  Created by Bryan Sample on 12/11/25.
//

import Fluent

struct CreateCircleInvitation: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("circle_invitations")
            .id()
            .field("invitation_code", .string, .required)
            .field("circle_id", .uuid, .required, .references("circles", "id"))
            .field("expires_at", .datetime, .required)
            .field("revoked", .bool, .required)
            .unique(on: "invitation_code")
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("circle_invitations").delete()
    }
}
