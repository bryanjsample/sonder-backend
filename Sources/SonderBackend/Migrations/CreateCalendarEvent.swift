//
//  CreateCalendarEvent.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent

struct CreateCalendarEvent: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("events")
            .id()
            .field("host_id", .uuid, .required, .references("users", "id"))
            .field("circle_id", .uuid, .required, .references("circles", "id"))
            .field("title", .string)
            .field("description", .string)
            .field("start_time", .datetime)
            .field("end_time", .datetime)
            .field("created_at", .datetime)
            .field("last_modified", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema("events").delete()
    }
}
