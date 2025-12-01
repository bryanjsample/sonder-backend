//
//  RefreshToken.swift
//  SonderBackend
//
//  Created by Bryan Sample on 12/1/25.
//

import Fluent
import Foundation
import Vapor

final class RefreshToken: Model, @unchecked Sendable {
    static let schema = "refresh_tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "user_id")
    var owner: User
    
    @Field(key: "expires_at")
    var expiresAt: Date

    @Field(key: "revoked")
    var revoked: Bool

    init() { }
    
    init(
        id: UUID? = nil,
        token: String,
        owner: User,
        expiresAt: Date,
        revoked: Bool
    ) throws {
        self.id = id
        self.token = token
        self.$owner.id = try owner.requireID()
        self.expiresAt = expiresAt
        self.revoked = revoked
    }
}

extension RefreshToken: ModelTokenAuthenticatable {
    static var valueKey: KeyPath<RefreshToken, Field<String>> { \.$token }
    static var userKey: KeyPath<RefreshToken, Parent<User>> { \.$owner }
    
    var isValid: Bool {
        self.expiresAt > Date.now && !self.revoked
    }
}
