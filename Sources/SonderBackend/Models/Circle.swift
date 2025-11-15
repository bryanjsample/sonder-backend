//
//  Circle.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Foundation

final class Circle: Model, @unchecked Sendable {
    static let schema = "circles"
    
    @ID(key: .id)
    var id: UUID?
    
    @Children(for: \.$circle)
    var users: [User]
    
    @Children(for: \.$circle)
    var events: [CalendarEvent]
    
    @Children(for: \.$circle)
    var posts: [Post]

    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "picture_url")
    var pictureUrl: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "last_modified", on: .update)
    var lastModified: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        description: String,
        pictureUrl: String? = nil,
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.pictureUrl = pictureUrl
    }
}
