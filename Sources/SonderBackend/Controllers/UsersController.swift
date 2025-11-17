//
//  UsersController.swift
//  tryingVapor
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor
import Fluent

struct UsersController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        
//        users.get(use: retrieveAll)
        users.post(use: createUser)
        
        users.group(":userID") { user in
            user.get(use: retrieve)
//            user.patch(use: edit)
//            user.delete(use: remove)
        }
    }
    
//    func retrieveAll(req: Request) async throws -> String {
//        "Users Homepage"
//        // this is a function that would respond with an array of all users in the database regardless of circle
//        // not necessary at this point
//    }
    
    func createUser(req: Request) async throws -> Response {
        // decode request
        let userDTO = try req.content.decode(UserDTO.self)
        
        try InputValidator.validateUser(userDTO)
        
        let sanitizedDTO = InputSanitizer.sanitizeUser(userDTO)
        
        let user = sanitizedDTO.toModel()
        // check if user exists based off email, send response and reset register process
        
        // SANITIZE INPUT
        
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
    
    //    func edit(req: Request) async throws -> String {
    //
    //    }
        
    //    func remove(req: Request) async throws -> {
    //
    //    }
    
}
