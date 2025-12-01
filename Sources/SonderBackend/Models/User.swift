//
//  User.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Foundation
import Vapor

final class User: Model, @unchecked Sendable, Authenticatable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @OptionalParent(key: "circle_id")
    var circle: Circle?

    @Children(for: \.$owner)
    var accessTokens: [AccessToken]
    
    @Children(for: \.$owner)
    var refreshTokens: [RefreshToken]

    @Children(for: \.$author)
    var posts: [Post]

    @Children(for: \.$author)
    var comments: [Comment]

    @Children(for: \.$host)
    var events: [CalendarEvent]

    @Field(key: "email")
    var email: String

    @Field(key: "first_name")
    var firstName: String

    @Field(key: "last_name")
    var lastName: String

    @Field(key: "username")
    var username: String?

    @Field(key: "picture_url")
    var pictureUrl: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "last_modified", on: .update)
    var lastModified: Date?

    init() {}

    init(
        id: UUID? = nil,
        circle: Circle? = nil,
        email: String,
        firstName: String,
        lastName: String,
        username: String? = nil,
        pictureUrl: String? = nil,
    ) throws {
        self.id = id
        self.$circle.id = try circle?.requireID()
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.pictureUrl = pictureUrl
    }

}

extension Date {
    func adding(minutes: Int) throws -> Date {
        guard let future = Calendar.current.date(byAdding: .minute, value: minutes, to: self) else {
            throw Abort(.internalServerError, reason: "Error adding timeframe to current date while issuing token")
        }
        return future
    }
    func adding(hours: Int) throws -> Date {
        guard let future =  Calendar.current.date(byAdding: .hour, value: hours, to: self) else {
            throw Abort(.internalServerError, reason: "Error adding timeframe to current date while issuing token")
        }
        return future
    }
    func adding(days: Int) throws -> Date {
        guard let future = Calendar.current.date(byAdding: .day, value: days, to: self) else {
            throw Abort(.internalServerError, reason: "Error adding timeframe to current date while issuing token")
        }
        return future
    }
}

extension User {
    func generateAccessToken() throws -> AccessToken {
        try .init(
            token: [UInt8].random(count: 16).base64,
            owner: self,
            expiresAt: Date.now.adding(hours: 1),
            revoked: false
        )
    }
    
    func generateRefreshToken() throws -> RefreshToken {
        try .init(
            token: [UInt8].random(count: 64).base64,
            owner: self,
            expiresAt: Date.now.adding(days: 60),
            revoked: false
        )
    }

    func exists(on database: any Database) async throws -> Bool {
        try await User.find(self.id, on: database) != nil
    }
}
