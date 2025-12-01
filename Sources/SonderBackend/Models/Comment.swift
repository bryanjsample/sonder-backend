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
        postID: Post,
        authorID: User,
        content: String,
    ) throws {
        self.id = id
        self.$post.id = try post.requireID()
        self.$author.id = try author.requireID()
        self.content = content
    }
}

extension Comment {
    func exists(on db: any Database) async throws -> Bool {
        try await SonderBackend.Comment.find(self.id, on: db) != nil
    }
}
