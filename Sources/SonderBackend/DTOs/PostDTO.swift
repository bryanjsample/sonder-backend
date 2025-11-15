//
//  PostDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Vapor

struct PostDTO: Content {
    
    var id: UUID?
    var circle: Circle
    var author: User
    var content: String
    var createdAt: Date?
    var lastModified: Date?
    
    func toModel() -> Post {
        let model = Post()
        model.id = self.id
        model.circle = self.circle
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
