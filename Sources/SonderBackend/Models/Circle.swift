//
//  Circle.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Vapor
import SonderDTOs

final class Circle: Model, @unchecked Sendable {
    static let schema = "circles"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "picture_url")
    var pictureUrl: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "last_modified", on: .update)
    var lastModified: Date?

    @Children(for: \.$circle)
    var users: [User]

    @Children(for: \.$circle)
    var events: [CalendarEvent]

    @Children(for: \.$circle)
    var posts: [Post]
    
    @Children(for: \.$circle)
    var invitations: [CircleInvitation]

    init() { }

    init(
        id: UUID? = nil,
        name: String,
        description: String,
        pictureUrl: String? = nil,
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.pictureUrl = pictureUrl
    }
}

extension Circle {
    func transferFieldsFromDTO(_ dto: CircleDTO) {
        self.name = dto.name
        self.description = dto.description
        if let picureUrl = dto.pictureUrl {
            self.pictureUrl = picureUrl
        }
    }
    
    func revokeAllInvitations(req: Request) async throws {
        let unrevokedInvitations = try await self.$invitations.query(on: req.db)
            .filter(\.$revoked == false)
            .all()
        for invitation in unrevokedInvitations {
            invitation.revoked = true
            try await invitation.update(on: req.db)
        }
    }
    
    func generateInvitationCode(req: Request) async throws -> CircleInvitation {
        try await self.revokeAllInvitations(req: req)
        return try .init(
            invitationCode: [UInt8].random(count: 16).base64,
            circle: self,
            expiresAt: Date.now.adding(days: 7),
            revoked: false
        )
    }
    
    func exists(on database: any Database) async throws -> Bool {
        try await Circle.find(self.id, on: database) != nil
    }
}
