//
//  User.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import struct Foundation.UUID

final class User: Model, @unchecked Sendable {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "username")
    var username: String
    
    @Parent(key: "circleID")
    var circle: Circle
    
//    @Field(key: "picture")
//    var picture: Data
    
    init() { }
    
    init(
        id: UUID? = nil,
        firstName: String,
        lastName: String,
        username: String,
        circleID: Circle.IDValue
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.$circle.id = circleID
    }
    
}
