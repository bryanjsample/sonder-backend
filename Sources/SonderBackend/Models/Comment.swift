//
//  Comment.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Foundation

final class Comment: Model, @unchecked Sendable {
    static let schema = "comments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "post_id")
    var post: Post
    
    @Parent(key: "author_id")
    var author: User
    
    @Field(key: "content")
    var content: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "last_modified", on: .update)
    var lastModified: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        postID: Post.IDValue,
        authorID: User.IDValue,
        content: String,
        createdAt: Date? = nil,
        lastModified: Date? = nil
    ) {
        self.id = id
        self.$post.id = postID
        self.$author.id = authorID
        self.content = content
        self.createdAt = createdAt
        self.lastModified = lastModified
    }
}
