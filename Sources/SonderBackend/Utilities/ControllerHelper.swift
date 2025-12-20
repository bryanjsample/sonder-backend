//
//  ControllerHelper.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/20/25.
//

import Vapor
import SonderDTOs

struct ControllerHelper {

    // VALIDATE AND SANITIZE ALL INCOMING IDS

    func getCircle(req: Request) async throws -> Circle {
        let circleIDParam = try req.parameters.require("circleID")
        guard let circleUUID = UUID(uuidString: circleIDParam) else {
            throw Abort(.badRequest, reason: "Invalid circle ID")
        }
        guard let circle = try await Circle.find(circleUUID, on: req.db) else {
            throw Abort(.notFound, reason: "Circle does not exist")
        }
        return circle
    }
    
    func getCircleViaInviteCode(req: Request, inviteCode: InvitationStringDTO) async throws -> Circle {
        
        // need to sanitize invite code
        
        guard let invitationModel = try await CircleInvitation.query(on: req.db)
            .filter(\.$invitationCode, .equal, inviteCode.invitation)
            .first() else {
            throw Abort(.notFound, reason: "Invite code does not exist")
        }
        
        // check if invite code is expired
        
        guard let circle = try await invitationModel.$circle.query(on: req.db).first() else {
            throw Abort(.notFound, reason: "There is not a circle attached to the invite code")
        }
        return circle
    }

    func getPost(req: Request) async throws -> Post {
        let postIDParam = try req.parameters.require("postID")
        guard let postUUID = UUID(uuidString: postIDParam) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }
        guard let post = try await Post.find(postUUID, on: req.db) else {
            throw Abort(.notFound, reason: "Post does not exist")
        }
        return post
    }

    func getCalendarEvent(req: Request) async throws -> CalendarEvent {
        let eventIDParam = try req.parameters.require("eventID")
        guard let eventUUID = UUID(uuidString: eventIDParam) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }
        guard
            let calendarEvent = try await CalendarEvent.find(
                eventUUID,
                on: req.db
            )
        else {
            throw Abort(.notFound, reason: "Event does not exist")
        }
        return calendarEvent
    }

    func getComment(req: Request) async throws -> Comment {
        let commentIDParam = try req.parameters.require("commentID")
        guard let commentUUID = UUID(uuidString: commentIDParam) else {
            throw Abort(.badRequest, reason: "invalid comment ID")
        }
        guard let comment = try await Comment.find(commentUUID, on: req.db)
        else {
            throw Abort(.notFound, reason: "Comment does not exist")
        }
        return comment
    }
    
    func getUser(req: Request) async throws -> User {
        let userIDparam = try req.parameters.require("userID")
        guard let userUUID = UUID(uuidString: userIDparam) else {
            throw Abort(.badRequest, reason: "invalid user ID")
        }
        guard let user = try await User.find(userUUID, on: req.db) else {
            throw Abort(.notFound, reason: "User does not exist")
        }
        return user
    }

    func sendResponseObject(
        dto: any Encodable,
        responseStatus: HTTPResponseStatus = .ok,
        headerContent: String = "application/json; charset=utf-8"
    ) throws -> Response {
        let body = try Response.Body(data: JSONEncoder().encode(dto))
        let response = Response(status: responseStatus, body: body)
        response.headers.replaceOrAdd(name: .contentType, value: headerContent)
        return response
    }
}
