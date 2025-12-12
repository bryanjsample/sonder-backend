//
//  CircleInvitation.swift
//  SonderBackend
//
//  Created by Bryan Sample on 12/11/25.
//

import Fluent
import Vapor

final class CircleInvitation: Model, @unchecked Sendable {
    static let schema = "circle_invitations"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "invitation_code")
    var invitationCode: String
    
    @Parent(key: "circle_id")
    var circle: Circle
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Field(key: "revoked")
    var revoked: Bool
    
    init () { }
    
    init(
        id: UUID? = nil,
        invitationCode: String,
        circle: Circle,
        expiresAt: Date,
        revoked: Bool
    ) throws {
        self.id = id
        self.invitationCode = invitationCode
        self.$circle.id = try circle.requireID()
        self.expiresAt = expiresAt
        self.revoked = revoked
    }
}
