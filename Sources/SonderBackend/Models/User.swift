//
//  User.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Foundation

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @OptionalParent(key: "circle_id")
    var circle: Circle?
    
    @Children(for: \.$author)
    var posts: [Post]
    
    @Children(for: \.$author)
    var comments: [Comment]
    
    @Children(for: \.$host)
    var events: [CalendarEvent]
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "username")
    var username: String?
    
    @Field(key: "picture_url")
    var pictureUrl: String?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "last_modified", on: .update)
    var lastModified: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        circleID: Circle.IDValue? = nil,
        email: String,
        firstName: String,
        lastName: String,
        username: String? = nil,
        pictureUrl: String? = nil,
    ) {
        self.id = id
        self.$circle.id = circleID
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.pictureUrl = pictureUrl
    }
    
}
