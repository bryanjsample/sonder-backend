//
//  UserToken.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/24/25.
//

import Vapor
import Fluent
import Foundation

final class UserToken: Model, @unchecked Sendable, ModelTokenAuthenticatable {
    static let schema = "user_tokens"
    
    static var valueKey: KeyPath<UserToken, Field<String>> { \.$value }
    static var userKey: KeyPath<UserToken, Parent<User>> { \.$user }
    
    var isValid: Bool { true }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() { }
    
    init(
        id: UUID? = nil,
        value: String,
        userID: User.IDValue
    ) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}


