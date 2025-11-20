//
//  ControllerHelper.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/20/25.
//

import Vapor

struct ControllerHelper {
    func getCircle(req: Request) async throws -> Circle {
        let circleIDParam = try req.parameters.require("circleID")
        // let circleID = sanitize and validate(param)
        guard let circleUUID = UUID(uuidString: circleIDParam) else {
            throw Abort(.badRequest, reason: "Invalid circle ID")
        }
        guard let circle = try await Circle.find(circleUUID, on: req.db) else {
            throw Abort(.notFound, reason: "Circle does not exist")
        }
        return circle
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
    
    func getPost(req: Request) async throws -> Post {
        let postIDParam = try req.parameters.require("postID")
        guard let postUUID = UUID(uuidString: postIDParam) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }
        guard let post = try await Post.find(postUUID, on: req.db) else {
            throw Abort(.notFound, reason: "Post does not exist")
        }
        return post
    }
}
