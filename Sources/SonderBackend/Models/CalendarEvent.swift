//
//  CalendarEvent.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Foundation

final class CalendarEvent: Model, @unchecked Sendable {
    static let schema = "events"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "host_id")
    var host: User

    @Parent(key: "circle_id")
    var circle: Circle

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "start_time")
    var startTime: Date

    @Field(key: "end_time")
    var endTime: Date

    //    @Field(key: "location")            best way to store? coords probably
    //    var location: Location

    //    @Children(key: "attendees")        this is a one->many relationship between event and an array of users
    //    var attendees: [User.IDValue]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "last_modified", on: .update)
    var lastModified: Date?

    init() {}

    init(
        id: UUID? = nil,
        host: User,
        circle: Circle,
        title: String,
        description: String,
        startTime: Date,
        endTime: Date,
        createdAt: Date? = nil
    ) throws {
        self.id = id
        self.$host.id = try host.requireID()
        self.$circle.id = try circle.requireID()
        self.title = title
        self.description = description
        self.startTime = startTime
        self.endTime = endTime
        self.createdAt = createdAt
    }
}

extension CalendarEvent {
    func exists(on database: any Database) async throws -> Bool {
        try await CalendarEvent.find(self.id, on: database) != nil
    }
}
