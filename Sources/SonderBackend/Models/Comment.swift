//
//  Comment.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import struct Foundation.UUID

final class Comment: Model, @unchecked Sendable {
    static let schema = "comments"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "postID")
    var post: Post
    
    @Parent(key: "authorID")
    var author: User
    
    @Field(key: "content")
    var content: String
    
//    @Field(key: "last_modified")
//    var lastModified: DateTime
    
    init() { }
    
    init(
        id: UUID? = nil,
        postID: Post.IDValue,
        authorID: User.IDValue,
        content: String
    ) {
        self.id = id
        self.$post.id = postID
        self.$author.id = authorID
        self.content = content
    }
}
