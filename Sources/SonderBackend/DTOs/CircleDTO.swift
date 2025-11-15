//
//  CircleDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Vapor

struct CircleDTO: Content {
    
    var id: UUID?
    var name: String
    var description: String
    var createdAt: Date?
    var lastModified: Date?
    
    func toModel() -> Circle {
        let model = Circle()
        model.id = self.id
        model.name = self.name
        model.description = self.description
        if let createdAt = self.createdAt {
            model.createdAt = createdAt
        }
        if let lastModified = self.lastModified {
            model.lastModified = lastModified
        }
        return model
    }
}
