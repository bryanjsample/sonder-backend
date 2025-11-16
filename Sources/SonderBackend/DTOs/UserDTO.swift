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
    var email: String
    var firstName: String
    var lastName: String
    var username: String?
    var pictureUrl: String?
    
    func toModel() -> User {
        let model = User()
        model.email = self.email
        model.firstName = self.firstName
        model.lastName = self.lastName
        if let username = self.username {
            model.username = username
        }
        if let pictureUrl = self.pictureUrl {
            model.pictureUrl = pictureUrl
        }
        return model
    }
}

extension UserDTO {
    init(from user: User) {
        self.id = user.id
        self.email = user.email
        self.firstName = user.firstName
        self.lastName = user.lastName
        if let username = user.username {
            self.username = username
        }
        if let pictureUrl = user.pictureUrl {
            self.pictureUrl = pictureUrl
        }
    }
}
