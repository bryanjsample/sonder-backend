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
    
    func getUser(req: Request) async throws -> User {
        let userIDParam = try req.parameters.require("userID")
        // let userID = sanitizeAndValidate(param)
        guard let userUUID = UUID(uuidString: userIDParam) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }
        guard let user = try await User.find(userUUID, on: req.db) else {
            throw Abort(.notFound, reason: "User does not exist")
        }
        return user
    }
    
    func createUser(req: Request) async throws -> UserDTO {
        let dto = try req.content.decode(UserDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        let user = sanitizedDTO.toModel()
        
        if try await userExists(user, on: req.db) {
            throw Abort(.badRequest, reason: "User already exists")
        } else {
            try await user.save(on: req.db)
            return UserDTO(from: user)
        }
    }
    
    func retrieve(req: Request) async throws -> UserDTO {
        let user = try await getUser(req: req)
        return UserDTO(from: user)
    }
    
    func edit(req: Request) async throws ->  UserDTO {
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
        let user = try await getUser(req: req)
        
        let dto = try req.content.decode(UserDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(sanitizedDTO, user)
        
        try await user.update(on: req.db)
        
        return UserDTO(from: user)
    }
    
    func remove(req: Request) async throws -> Response {
        let user = try await getUser(req: req)
        try await user.delete(on: req.db)
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
    
    func userExists(_ user: User, on db: any Database) async throws -> Bool {
        return try await User.find(user.id, on: db) != nil
    }
    
    func validateAndSanitize(_ userDTO: UserDTO) throws -> UserDTO {
        try InputValidator.validateUser(userDTO)
        let sanitizedDTO = InputSanitizer.sanitizeUser(userDTO)
        return sanitizedDTO
    }
    
}
