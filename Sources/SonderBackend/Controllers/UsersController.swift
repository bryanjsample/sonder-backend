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
//            user.patch(use: edit)
//            user.delete(use: remove)
        }
    }
    
    func createUser(req: Request) async throws -> Response {
        let dto = try req.content.decode(UserDTO.self)
        
        let user = try validateAndSanitize(dto)
        
        if try await userExists(user, on: req.db) {
            throw Abort(.badRequest, reason: "User already exists")
        } else {
            try await user.save(on: req.db)
            let dto = UserDTO(from: user)
            return Response(status: .created, body: .init(data: try JSONEncoder().encode(dto)))
        }
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
    
    func validateAndSanitize(_ userDTO: UserDTO) throws -> User {
        try InputValidator.validateUser(userDTO)
        
        let sanitizedDTO = InputSanitizer.sanitizeUser(userDTO)
        let sanitizedUser = sanitizedDTO.toModel()
        return sanitizedUser
    }
    
    func userExists(_ user: User, on db: any Database) async throws -> Bool {
        return try await User.query(on: db)
            .filter(\.$email == user.email)
            .first() != nil
    }
    
    func retrieve(req: Request) async throws -> UserDTO {
        let userIDParam = try req.parameters.require("userID")
        guard let userUUID = UUID(uuidString: userIDParam) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }
        guard let user = try await User.find(userUUID, on: req.db) else {
            throw Abort(.notFound, reason: "User does not exist")
        }
        return UserDTO(from: user)
    }
    
    //    func edit(req: Request) async throws ->  {
    //
    //    }
        
    //    func remove(req: Request) async throws -> {
    //
    //    }
    
}
