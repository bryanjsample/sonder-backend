//
//  MeController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/29/25.
//

import Vapor
import Fluent

struct MeController: RouteCollection {
    
    let helper = ControllerHelper()
    
    func boot(routes: any RoutesBuilder) throws {
        let me = routes.grouped("me")
        
        me.get(use: retrieve)
        me.patch(use: edit)
        me.delete(use: remove)
        
    }
    
    
    // authorize each request to this endpoint
    
    func retrieve(req: Request) async throws -> UserDTO {
        let me = try await getMe(req: req)
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
        let me = try await getMe(req: req)
        
        let dto = try req.content.decode(UserDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(sanitizedDTO, me)
        
        try await me.update(on: req.db)
        
        return UserDTO(from: me)
        
    }
    
    func remove(req: Request) async throws -> Response {
        let me = try await getMe(req: req)
        try await me.delete(on: req.db)
        return Response(status: .ok, body: .init(stringLiteral: "User was removed from database"))
    }
    
    func userExists(_ user: User, on db: any Database) async throws -> Bool {
        return try await User.find(user.id, on: db) != nil
    }
    
    func getMe(req: Request) async throws -> User {
        guard let accessToken = try req.accessToken else {
            throw Abort(.unauthorized, reason: "Access token not included or invalid")
        }
        guard let token = try await UserToken.query(on: req.db)
            .filter(\.$value == accessToken)
            .first() else {
            throw Abort(.unauthorized, reason: "Access token not found in database")
        }
        return try await token.$owner.get(on: req.db)
    }
    
    func validateAndSanitize(_ userDTO: UserDTO) throws -> UserDTO {
        try InputValidator.validateUser(userDTO)
        let sanitizedDTO = InputSanitizer.sanitizeUser(userDTO)
        return sanitizedDTO
    }
    
}
