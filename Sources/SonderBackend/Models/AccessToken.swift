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
    static let schema = "user_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "value")
    var value: String

    @Parent(key: "user_id")
    var owner: User

    init() {}

    init(
        id: UUID? = nil,
        value: String,
        userID: User.IDValue
    ) {
        self.id = id
        self.value = value
        self.$owner.id = userID
    }
}

extension AccessToken: ModelTokenAuthenticatable {
    static var valueKey: KeyPath<AccessToken, Field<String>> { \.$value }
    static var userKey: KeyPath<AccessToken, Parent<User>> { \.$owner }

    var isValid: Bool { true }
}
