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
    
    @Parent(key: "authorID")
    var author: User
    
    @Field(key: "content")
    var content: String
    
//    @Field(key: "attachments")         best way to store a number of attachments? mainly pictures
//    var attachments: [Data]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "last_modified", on: .update)
    var lastModified: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        authorID: User.IDValue,
        content: String,
        createdAt: Date? = nil,
        lastModified: Date? = nil,
    ) {
        self.id = id
        self.$author.id = authorID
        self.content = content
        self.createdAt = createdAt
        self.lastModified = lastModified
    }
}
