//
//  AccessToken.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/24/25.
//

import Fluent
import Foundation
import Vapor

final class AccessToken: Model, @unchecked Sendable {
    static let schema = "access_tokens"

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

    init() {}

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

extension AccessToken: ModelTokenAuthenticatable {
    static var valueKey: KeyPath<AccessToken, Field<String>> { \.$token }
    static var userKey: KeyPath<AccessToken, Parent<User>> { \.$owner }

    var isValid: Bool {
        self.expiresAt > Date.now && !self.revoked
    }
}
