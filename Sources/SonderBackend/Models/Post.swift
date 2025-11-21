//
//  Post.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Foundation

final class Post: Model, @unchecked Sendable {
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "circle_id")
    var circle: Circle
    
    @Parent(key: "author_id")
    var author: User
    
    @Children(for: \.$post)
    var comments: [Comment]
    
    @Field(key: "content")
    var content: String
    
//    @Field(key: "attachments")         best way to store a number of attachments? mainly pictures
//    var attachments: [Data]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "last_modified", on: .update)
    var lastModified: Date?
    
//    @Children(for: \.$post)
//    var comments = [Comment]
//    
//    @Children(for: \.$post)
    
    init() { }
    
    init(
        id: UUID? = nil,
        circle: Circle,
        author: User,
        content: String,
        createdAt: Date? = nil
    ) throws {
        self.id = id
        self.$circle.id = try circle.requireID()
        self.$author.id = try author.requireID()
        self.content = content
        self.createdAt = createdAt
    }
}
