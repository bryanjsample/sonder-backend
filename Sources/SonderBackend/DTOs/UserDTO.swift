//
//  UserDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Vapor

struct UserDTO: Content {
    
    var id: UUID?
    var circle: Circle
    var firstName: String
    var lastName: String
    var username: String
    var createdAt: Date?
    var lastModified: Date?
    
    func toModel() -> User {
        let model = User()
        model.circle = self.circle
        model.firstName = self.firstName
        model.lastName = self.lastName
        model.username = self.username
        if let createdAt = self.createdAt {
            model.createdAt = createdAt
        }
        if let lastModified = self.lastModified {
            model.lastModified = lastModified
        }
        return model
    }
}
