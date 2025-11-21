//
//  CommentDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor

struct CommentDTO: Content {
    
    var id: UUID?
    var postID: UUID
    var authorID: UUID
    var content: String
    var createdAt: Date?
    
    func toModel() -> Comment {
        let model = Comment()
        model.$post.id = self.postID
        model.$author.id = self.authorID
        model.content = self.content
        model.createdAt = self.createdAt
        return model
    }
}

extension CommentDTO {
    
    init(from comment: Comment) {
        self.id = comment.id ?? nil
        self.postID = comment.$post.id
        self.authorID = comment.$author.id
        self.content = comment.content
        self.createdAt = comment.createdAt ?? nil
    }
}
