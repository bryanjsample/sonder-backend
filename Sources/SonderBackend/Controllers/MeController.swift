//
//  MeController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/29/25.
//

import Vapor
import Fluent

struct MeController: RouteCollection {
    
    func boot(routes: any RoutesBuilder) throws {
        let meProtected = routes.grouped("me").grouped(UserToken.authenticator())
        
        meProtected.get(use: retrieve)
        meProtected.patch(use: edit)
        meProtected.delete(use: remove)
        
        meProtected.group("events") { myEvents in
            myEvents.get(use: retrieveEvents)
        }
        
    }
    
    func retrieve(req: Request) async throws -> UserDTO {
        let me = try req.auth.require(User.self)
        return UserDTO(from: me)
    }
    
    func edit(req: Request) async throws -> UserDTO {
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
        let me = try req.auth.require(User.self)
        
        let dto = try req.content.decode(UserDTO.self)
        let sanitizedDTO = try dto.validateAndSanitize()
        
        transferFields(sanitizedDTO, me)
        
        try await me.update(on: req.db)
        
        return UserDTO(from: me)
        
    }
    
    func remove(req: Request) async throws -> Response {
        let me = try req.auth.require(User.self)
        try await me.delete(on: req.db)
        return Response(status: .ok, body: .init(stringLiteral: "User was removed from database"))
    }

    func retrieveEvents(req: Request) async throws -> [CalendarEventDTO] {
        
        // parse query parameters such as circle= role= from=&to= page=1&per=20
        
        let user = try req.auth.require(User.self)
        return try await CalendarEvent.query(on: req.db)
            .filter(\.$host.$id == user.requireID())
            .all()
            .map { CalendarEventDTO(from: $0) }
    }
    
    func retrievePosts(req: Request) async throws -> [PostDTO] {
        
        // parse query parameters to reduce runtime query speed
        
        let user = try req.auth.require(User.self)
        return try await Post.query(on: req.db)
            .filter(\.$author.$id == user.requireID())
            .all()
            .map { PostDTO(from: $0) }
        
    }
}
