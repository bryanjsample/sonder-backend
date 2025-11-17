//
//  UsersController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.post(use: createUser)
        
        users.group(":userID") { user in
            user.get(use: retrieve)
            user.patch(use: edit)
            user.delete(use: remove)
        }
    }
    
    func createUser(req: Request) async throws -> Response {
        let dto = try req.content.decode(UserDTO.self)
        
        let sanitizedDTO = try validateAndSanitize(dto)
        
        let user = sanitizedDTO.toModel()
        
        if try await userExists(user, on: req.db) {
            throw Abort(.badRequest, reason: "User already exists")
        } else {
            try await user.save(on: req.db)
            let dto = UserDTO(from: user)
            return Response(status: .created, body: .init(data: try JSONEncoder().encode(dto)))
        }
    }
    
    func retrieve(req: Request) async throws -> Response {
        let userIDParam = try req.parameters.require("userID")
        guard let userUUID = UUID(uuidString: userIDParam) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }
        guard let user = try await User.find(userUUID, on: req.db) else {
            throw Abort(.notFound, reason: "User does not exist")
        }
        let dto = UserDTO(from: user)
        return Response(status: .ok, body: .init(data: try JSONEncoder().encode(dto)))
    }
    
    func edit(req: Request) async throws ->  Response {
        func transferFields(user: User, dto: UserDTO) {
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
        let userIDParam = try req.parameters.require("userID")
        guard let userUUID = UUID(uuidString: userIDParam) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }
        
        guard let user = try await User.find(userUUID, on: req.db) else {
            throw Abort(.notFound, reason: "User does not exist")
        }
        
        print(user)
        
        let dto = try req.content.decode(UserDTO.self)
        
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(user: user, dto: sanitizedDTO)
        
        print(user)
        
        print(user.id?.uuidString ?? "no id on sanitized user")
        
        if try await userExists(user, on: req.db) {
            try await user.update(on: req.db)
        } else {
            throw Abort(.notFound, reason: "User does not exist")
        }
        
        let responseDTO = UserDTO(from: user)
        return Response(status: .ok, body: .init(data: try JSONEncoder().encode(responseDTO)))
    }
    
    func remove(req: Request) async throws -> Response {
        let dto = try req.content.decode(UserDTO.self)
        
        let sanitizedDTO = try validateAndSanitize(dto)
        
        let user = sanitizedDTO.toModel()
        
        if try await userExists(user, on: req.db) {
            try await user.delete(on: req.db)
        } else {
            throw Abort(.notFound, reason: "User does not exist")
        }
        return Response(status: .ok, body: .init(stringLiteral: "User was removed from database"))
    }
    
        /*
         sample response from an OAuth request
         {
           "sub": "1039283423949234",
           "email": "bryan@gmail.com",
           "email_verified": true,
           "name": "Bryan Sample",
           "given_name": "Bryan",
           "family_name": "Sample",
           "picture": "https://lh3.googleusercontent.com/.../photo.jpg"
         }
         */
    
    func validateAndSanitize(_ userDTO: UserDTO) throws -> UserDTO {
        try InputValidator.validateUser(userDTO)
        let sanitizedDTO = InputSanitizer.sanitizeUser(userDTO)
        return sanitizedDTO
    }
    
    func userExists(_ user: User, on db: any Database) async throws -> Bool {
        return try await User.find(user.id, on: db) != nil
    }
    
}
