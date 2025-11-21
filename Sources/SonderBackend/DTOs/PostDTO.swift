//
//  PostDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor

struct PostDTO: Content {
    
    var id: UUID?
    var circleID: UUID
    var authorID: UUID
    var content: String
    var createdAt: Date?
    
    func toModel() -> Post {
        let model = Post()
        model.id = self.id
        model.$circle.id = self.circleID
        model.$author.id = self.authorID
        model.content = self.content
        model.createdAt = self.createdAt
        return model
    }
}

extension PostDTO {

    init(from post: Post) {
        self.id = post.id ?? nil
        self.circleID = post.$circle.id
        self.authorID = post.$author.id
        self.content = post.content
        self.createdAt = post.createdAt ?? nil
    }
    
}
