//
//  MeController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/29/25.
//

import Fluent
import SonderDTOs
import Vapor

struct MeController: RouteCollection {

    let helper = ControllerHelper()

    func boot(routes: any RoutesBuilder) throws {
        let meProtected = routes.grouped("me")
            .grouped(AccessToken.authenticator())

        meProtected.get(use: retrieve)
        meProtected.patch(use: edit)
        meProtected.delete(use: remove)

        meProtected.group("events") { myEvents in
            myEvents.get(use: retrieveEvents)
        }
        
        meProtected.group("posts") { myPosts in
            myPosts.get(use: retrievePosts)
        }

    }

    func retrieve(req: Request) async throws -> Response {
        let myself = try req.auth.require(User.self)
        let dto = UserDTO(from: myself)
        return try helper.sendResponseObject(dto: dto)
    }

    func edit(req: Request) async throws -> Response {
        func transferFields(_ dto: UserDTO, _ user: User, ) {
            user.email = dto.email
            user.firstName = dto.firstName
            user.lastName = dto.lastName
            if let username = dto.username {
                user.username = username
            }
            if let pictureUrl = dto.pictureUrl {
                user.pictureUrl = pictureUrl
            }
        }
        let myself = try req.auth.require(User.self)

        let dto = try req.content.decode(UserDTO.self)
        let sanitizedDTO = try dto.validateAndSanitize()

        transferFields(sanitizedDTO, myself)

        try await myself.update(on: req.db)

        let resDTO = UserDTO(from: myself)
        return try helper.sendResponseObject(dto: resDTO)

    }

    func remove(req: Request) async throws -> Response {
        let myself = try req.auth.require(User.self)
        try await myself.delete(on: req.db)
        return Response(
            status: .ok,
            body: .init(stringLiteral: "User was removed from database")
        )
    }

    func retrieveEvents(req: Request) async throws -> Response {

        // parse query parameters such as circle= role= from=&to= page=1&per=20

        let myself = try req.auth.require(User.self)
        let eventDTOs = try await CalendarEvent.query(on: req.db)
            .filter(\.$host.$id == myself.requireID())
            .all()
            .map { CalendarEventDTO(from: $0) }
        return try helper.sendResponseObject(dto: eventDTOs)
    }

    func retrievePosts(req: Request) async throws -> Response {

        // parse query parameters to reduce runtime query speed

        let myself = try req.auth.require(User.self)
        let postDTOs = try await Post.query(on: req.db)
            .filter(\.$author.$id == myself.requireID())
            .all()
            .map { PostDTO(from: $0) }
        return try helper.sendResponseObject(dto: postDTOs)

    }
}

extension UserDTO {
    init(from user: User) {
        self.init(
            id: user.id,
            email: user.email,
            firstName: user.firstName,
            lastName: user.lastName,
            username: user.username,
            pictureUrl: user.pictureUrl,
        )
        self.id = user.id ?? nil
        self.email = user.email
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.username = user.username ?? nil
        self.pictureUrl = user.pictureUrl ?? nil
    }

    func toModel() -> User {
        let model = User()

        model.id = self.id ?? nil
        model.email = self.email
        model.firstName = self.firstName
        model.lastName = self.lastName
        model.username = self.username ?? nil
        model.pictureUrl = self.pictureUrl ?? nil

        return model
    }
}
