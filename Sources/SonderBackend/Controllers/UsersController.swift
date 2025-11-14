//
//  UsersController.swift
//  tryingVapor
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor

struct UsersController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        
        users.get(use: retrieveAll)
        users.post(use: createUser)
        
        users.group(":userId") { user in
            user.get(use: retrieve)
        }
    }
    
    func retrieveAll(req: Request) async throws -> String {
        "Users Homepage"
    }
    
    func createUser(req: Request) async throws -> String {
        "Create a new user"
    }
    
    func retrieve(req: Request) async throws -> String {
        let userId = req.parameters.get("userId")!
        return "User id = \(userId)"
    }
}
