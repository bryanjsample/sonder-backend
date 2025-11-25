//
//  UserTokenDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/24/25.
//

import Vapor

struct UserTokenDTO: Content {
    var value: String
    var ownerID: UUID
    
}

extension UserTokenDTO {
    init(from token: UserToken) {
        self.value = token.value
        self.ownerID = token.$owner.id
    }
}
