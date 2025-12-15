//
//  GroupsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Fluent
import SonderDTOs
import Vapor

struct CirclesController: RouteCollection {

    let helper = ControllerHelper()

    func boot(routes: any RoutesBuilder) throws {
        let circlesProtected = routes.grouped("circles").grouped(
            AccessToken.authenticator()
        )

        circlesProtected.post(use: createCircle)
        
        circlesProtected.group("invitation") { invitation in
            invitation.post(use: joinCircleViaInvitation)
        }

        circlesProtected.group(":circleID") { circle in
            circle.get(use: retrieve)
            circle.patch(use: edit)
            circle.delete(use: remove)
        }

        circlesProtected.group(":circleID", "users") { circleUsers in
            circleUsers.get(use: retrieveUsers)
        }

        circlesProtected.group(":circleID", "feed") { circleFeed in
            circleFeed.get(use: retrieveFeed)
        }
    }

    func createCircle(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        
        if user.isInCircle() {
            throw Abort(.conflict, reason: "User is already in a circle")
        }
        
        var circle: Circle

        do {
            let dto = try req.content.decode(CircleDTO.self)
            let sanitizedDTO = try dto.validateAndSanitize()
            circle = sanitizedDTO.toModel()
        } catch is ValidationError {
            throw Abort(.badRequest, reason: "Circle cannot be validated")
        }

        if try await circle.exists(on: req.db) {
            throw Abort(.conflict, reason: "Circle already exists")
        } else {
            try await circle.save(on: req.db)
            let dto = CircleDTO(from: circle)
            return try helper.sendResponseObject(dto: dto, responseStatus: .created)
        }
    }
    
    func joinCircleViaInvitation(req: Request) async throws -> Response {
        let user = try req.auth.require(User.self)
        
        if user.isInCircle() {
            throw Abort(.conflict, reason: "User is already in a circle")
        }
        
        let dto = try req.content.decode(InvitationStringDTO.self)
        let circle = try await helper.getCircleViaInviteCode(req: req, inviteCode: dto)
        guard let circleID = circle.id else {
            throw Abort(.notFound, reason: "Circle ID is not found")
        }
        user.$circle.id = circleID
        try await user.update(on: req.db)
        
        let resDTO = CircleDTO(from: circle)
        return try helper.sendResponseObject(dto: resDTO)
    }

    func retrieve(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }
        
        let dto = CircleDTO(from: circle)
        return try helper.sendResponseObject(dto: dto)
    }

    func edit(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }

        do {
            let dto = try req.content.decode(CircleDTO.self)
            let sanitizedDTO = try dto.validateAndSanitize()
            circle.transferFieldsFromDTO(sanitizedDTO)
        } catch is ValidationError {
            throw Abort(.badRequest, reason: "Circle cannot be validated")
        }

        try await circle.update(on: req.db)

        let resDTO = CircleDTO(from: circle)
        return try helper.sendResponseObject(dto: resDTO)
    }

    func remove(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }
        
        try await circle.delete(on: req.db)
        return Response(
            status: .ok,
            body: .init(stringLiteral: "Circle was removed from database")
        )
    }

    func retrieveUsers(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }

        let userDTOs = try await circle.$users.query(on: req.db).all()
            .map { UserDTO(from: $0) }
        return try helper.sendResponseObject(dto: userDTOs)
    }

    func retrieveFeed(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }

        // ADD IN PAGINATION FUNCTIONALITY

        let posts = try await Post.query(on: req.db)
            .filter(\.$circle.$id == circle.id!)
            .with(\.$circle)
            .with(\.$author)
            .all()
        let events = try await CalendarEvent.query(on: req.db)
            .filter(\.$circle.$id == circle.id!)
            .with(\.$circle)
            .with(\.$host)
            .all()
        let postDTOs = posts.map { FeedItemDTO.post(PostDTO(from: $0)) }
        let eventDTOs = events.map { FeedItemDTO.event(CalendarEventDTO(from: $0)) }
        
        let merged = (postDTOs + eventDTOs).sorted {
            $0.createdAt! > $1.createdAt!
        }

        let dto = FeedResponseDTO(items: merged)
        return try helper.sendResponseObject(dto: dto)
    }

}

extension CircleDTO {
    init(from circle: Circle) {
        self.init(
            id: circle.id ?? nil,
            name: circle.name,
            description: circle.description,
            pictureUrl: circle.pictureUrl ?? nil
        )
    }

    func toModel() -> Circle {
        let model = Circle()
        model.id = self.id ?? nil
        model.name = self.name
        model.description = self.description
        model.pictureUrl = self.pictureUrl ?? nil
        return model
    }
}
