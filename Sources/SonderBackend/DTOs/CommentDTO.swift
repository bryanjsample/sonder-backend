//
//  CommentDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor

struct CommentDTO: Content {
    
    var id: UUID?
    var post: Post
    var author: User
    var content: String
    
    func toModel() -> Comment {
        let model = Comment()
        model.post = self.post
        model.author = self.author
        model.content = self.content
        return model
    }
}
