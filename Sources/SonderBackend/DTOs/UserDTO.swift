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
    var username: String
    var pictureUrl: String?
    
    func toModel() -> User {
        let model = User()
        model.email = self.email
        model.firstName = self.firstName
        model.lastName = self.lastName
        model.username = self.username
        if let pictureUrl = self.pictureUrl {
            model.pictureUrl = pictureUrl
        }
        return model
    }
}
