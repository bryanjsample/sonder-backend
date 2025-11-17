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
        
        print("dto = \(self)")
        
        if let id = self.id {
            model.id = id
        } else {
            model.id = nil
        }
        
        model.email = self.email
        model.firstName = self.firstName
        model.lastName = self.lastName
        
        if let username = self.username {
            model.username = username
        } else {
            model.username = nil
        }
        if let pictureUrl = self.pictureUrl {
            model.pictureUrl = pictureUrl
        } else {
            model.pictureUrl = nil
        }
        
        print("model = \(model)")
        
        return model
    }
    
}

extension UserDTO {
    init() {
        self.id = nil
        self.email = ""
        self.firstName = ""
        self.lastName = ""
        self.username = nil
        self.pictureUrl = nil
    }
    
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
