//
//  CommentsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor

struct CommentsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let comments = routes.grouped("circles", ":circleID", "posts", ":postID", "comments")
        
        comments.get(use: retrieveAll)
        comments.post(use: createComment)
        
        comments.group(":commentID") { comment in
            comment.get(use: retrieve)
//            comment.patch(use: edit)
//            comment.delete(use: remove)
        }
    }
    
    func retrieveAll(req: Request) async throws -> String {
        let circleID = req.parameters.get("circleID")!
        let postID = req.parameters.get("postID")!
        return "These are circle \(circleID)'s post \(postID) comments"
    }
    
    func retrieve(req: Request) async throws -> String {
        let circleID = req.parameters.get("circleID")!
        let postID = req.parameters.get("postID")!
        let commentID = req.parameters.get("commentID")!
        return "These are circle \(circleID)'s post \(postID) comment ID = \(commentID)"
    }
    
    func createComment(req: Request) async throws -> String {
        "Create a new comment"
    }
    
//    func edit(req: Request) async throws -> String {
//
//    }
    
//    func remove(req: Request) async throws -> {
//
//    }
    
}
