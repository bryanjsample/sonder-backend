//
//  PostDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor

struct PostDTO: Content {
    
    var id: UUID?
    var circle: Circle
    var author: User
    var content: String
    var createdAt: Date?
    
    func toModel() -> Post {
        let model = Post()
        model.id = self.id
        model.circle = self.circle
        model.author = self.author
        model.content = self.content
        model.createdAt = self.createdAt
        return model
    }
}

extension PostDTO {

    init(from post: Post) {
        self.id = post.id ?? nil
        self.circle = post.circle
        self.author = post.author
        self.content = post.content
        self.createdAt = post.createdAt
    }
    
}
