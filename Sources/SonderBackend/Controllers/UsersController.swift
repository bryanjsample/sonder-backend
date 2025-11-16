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
        
        users.get(use: retrieveAll)
        users.post(use: createUser)
        
        users.group(":userID") { user in
            user.get(use: retrieve)
        }
    }
    
    func retrieveAll(req: Request) async throws -> String {
        "Users Homepage"
    }
    
    func createUser(req: Request) async throws -> Response {
        // decode request
        let userDTO = try req.content.decode(UserDTO.self)
        let user = userDTO.toModel()
        // check if user exists based off email, send response and reset register process
        if try await userExists(user, on: req.db) {
            return Response(status: .conflict, body: "User already exists")
        } else {
            try await user.save(on: req.db)
            return Response(status: .created, body: "User created")
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
    
    func retrieve(req: Request) async throws -> String {
        let userID = req.parameters.get("userID")!
        return "User ID = \(userID)"
    }
}
