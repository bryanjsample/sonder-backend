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
        return User(
            email: self.email,
            firstName: self.firstName,
            lastName: self.lastName,
            username: self.username ?? nil,
            pictureUrl: self.pictureUrl ?? nil
        )
    }
}

extension UserDTO {
    init(from user: User) {
        if let userID = user.id {
            self.id = userID
        }
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
