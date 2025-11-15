//
//  CommentDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Vapor

struct CommentDTO: Content {
    
    var id: UUID?
    var post: Post
    var author: User
    var content: String
    var createdAt: Date?
    var lastModified: Date?
    
    func toModel() -> Comment {
        let model = Comment()
        model.post = self.post
        model.author = self.author
        model.content = self.content
        if let createdAt = self.createdAt {
            model.createdAt = createdAt
        }
        if let lastModified = self.lastModified {
            model.lastModified = lastModified
        }
        return model
    }
}
