//
//  UserDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

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
        
        model.id = self.id ?? nil
        model.email = self.email
        model.firstName = self.firstName
        model.lastName = self.lastName
        model.username = self.username ?? nil
        model.pictureUrl = self.pictureUrl ?? nil
        
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
        self.id = user.id ?? nil
        self.email = user.email
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.username = user.username ?? nil
        self.pictureUrl = user.pictureUrl ?? nil
    }
}
