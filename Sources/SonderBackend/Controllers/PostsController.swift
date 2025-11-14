//
//  PostsController.swift
//  tryingVapor
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor

struct PostsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("circles", ":circleId", "posts")
        
        posts.get(use: retrieveAll)
        
        posts.group(":postId") { post in
            post.get(use: retrieve)
        }
    }
    
    func retrieveAll(req: Request) async throws -> String {
        let circleId = req.parameters.get("circleId")!
        return "These are Circle \(circleId)'s posts"
    }
    
    func retrieve(req: Request) async throws -> String {
        let circleId = req.parameters.get("circleId")!
        let postId = req.parameters.get("postId")!
        return "Circle \(circleId)'s post id = \(postId)"
    }
}
