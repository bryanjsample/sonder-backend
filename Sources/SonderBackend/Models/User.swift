//
//  User.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Foundation
import Vapor
import SonderDTOs

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
    
    func generateAccessToken(req: Request) async throws -> AccessToken {
        try await self.revokeAllAccessTokens(req: req)
        return try .init(
            token: [UInt8].random(count: 16).base64,
            owner: self,
            expiresAt: Date.now.adding(hours: 1),
            revoked: false
        )
    }
    
    func generateRefreshToken(req: Request) async throws -> RefreshToken {
        try await self.revokeAllRefreshTokens(req: req)
        return try .init(
            token: [UInt8].random(count: 64).base64,
            owner: self,
            expiresAt: Date.now.adding(days: 60),
            revoked: false
        )
    }
    
    func retrieveAccessToken(req: Request) async throws -> AccessToken? {
        req.logger.info("inside retrieveAccessToken")
        guard let accessToken = try await self.$accessTokens.query(on: req.db)
            .filter(\.$revoked == false)
            .first() else {
            req.logger.info("User doesn't have a registered access token")
            return nil
        }
        if accessToken.isValid {
            return accessToken
        } else {
            accessToken.revoked = true
            try await accessToken.update(on: req.db)
            req.logger.info("access token is invalid, need to consult refresh token")
            return nil
        }
    }
    
    func retrieveRefreshToken(req: Request) async throws -> RefreshToken? {
        req.logger.info("inside retrieveRefreshToken")
        guard let refreshToken = try await self.$refreshTokens.query(on: req.db)
            .filter(\.$revoked == false)
            .first() else {
            req.logger.info("User doesn't have a registered refresh token.")
            throw Abort.redirect(to: "/auth/google")
        }
        if refreshToken.isValid {
            return refreshToken
        } else {
            refreshToken.revoked = true
            try await refreshToken.update(on: req.db)
            req.logger.info("refresh token is invalid, need to log back in")
            throw Abort.redirect(to: "/auth/google")
        }
    }
    
    func revokeAllAccessTokens(req: Request) async throws {
        let accessTokens = try await self.$accessTokens.query(on: req.db).all()
        for token in accessTokens {
            token.revoked = true
            try await token.update(on: req.db)
        }
    }
    
    func revokeAllRefreshTokens(req: Request) async throws {
        let refreshTokens = try await self.$refreshTokens.query(on: req.db).all()
        for token in refreshTokens {
            token.revoked = true
            try await token.update(on: req.db)
        }
    }
    
    func revokeAllTokens(req: Request) async throws {
        try await revokeAllAccessTokens(req: req)
        try await revokeAllRefreshTokens(req: req)
    }
    
    func isCircleMember(_ circle: Circle) -> Bool {
        guard let circleID = circle.id else {
            return false
        }
        if let userCircleID = self.$circle.id {
            return userCircleID == circleID
        } else {
            return false
        }
    }
    
    func isPostAuthor(_ post: Post) -> Bool {
        if let userID = self.id {
            return userID == post.$author.id
        } else {
            return false
        }
    }
    
    func isCommentAuthor(_ comment: Comment) -> Bool {
        if let userID = self.id {
            return userID == comment.$author.id
        } else {
            return false
        }
    }
    
    func isEventHost(_ event: CalendarEvent) -> Bool {
        if let userID = self.id {
            return userID == event.$host.id
        } else {
            return false
        }
    }

    func exists(on database: any Database) async throws -> Bool {
        try await User.find(self.id, on: database) != nil
    }
}
