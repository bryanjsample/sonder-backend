//
//  PostsController.swift
//  tryingVapor
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor

struct PostsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("circles", ":circleID", "posts")
        
        posts.get(use: retrieveAll)
        posts.post(use: createPost)
        
        posts.group(":postID") { post in
            post.get(use: retrieve)
//            post.patch(use: edit)
//            post.delete(use: remove)
        }
    }
    
    func retrieveAll(req: Request) async throws -> String {
        let circleID = req.parameters.get("circleID")!
        return "These are Circle \(circleID)'s posts"
    }
    
    func retrieve(req: Request) async throws -> String {
        let circleID = req.parameters.get("circleID")!
        let postID = req.parameters.get("postID")!
        return "Circle \(circleID)'s post ID = \(postID)"
    }
    
    func createPost(req: Request) async throws -> String {
        "Create a new post"
    }
    
//    func edit(req: Request) async throws -> String {
//
//    }
    
//    func remove(req: Request) async throws -> {
//
//    }
    
}
