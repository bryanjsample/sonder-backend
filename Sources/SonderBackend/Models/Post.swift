//
//  Post.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import struct Foundation.UUID

final class Post: Model, @unchecked Sendable {
    static let schema = "posts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "authorID")
    var author: User
    
    @Field(key: "content")
    var content: String
    
//    @Field(key: "attachments")
//    var attachments: [Data]
//
//    @Field(key: "last_modified")
//    var lastModified: Date
    
    init() { }
    
    init(
        id: UUID? = nil,
        authorID: User.IDValue,
        content: String
    ) {
        self.id = id
        self.$author.id = authorID
        self.content = content
    }
}
