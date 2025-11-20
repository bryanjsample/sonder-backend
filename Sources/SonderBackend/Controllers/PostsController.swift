//
//  PostsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor
import Fluent

struct PostsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("circles", ":circleID", "posts")
        
        posts.get(use: retrieveCirclePosts)
        
        posts.group(":postID") { post in
            post.get(use: retrievePost)
            post.patch(use: editPost)
            post.delete(use: removePost)
        }
        
        posts.group(":userID") { userPosts in
            userPosts.post(use: createPost)
            userPosts.get(use: retrieveUserPosts)
        }
    }
    
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
    
    func createPost(req: Request) async throws -> PostDTO {
        let circle = try await getCircle(req: req)
        let user = try await getUser(req: req)
        
        var postDTO = try req.content.decode(PostDTO.self)
        
        postDTO.circle = circle
        postDTO.author = user
        
        let sanitizedDTO = try validateAndSanitize(postDTO)
        let post = sanitizedDTO.toModel()
        
        if try await postExists(post, on: req.db) {
            throw Abort(.badRequest, reason: "Post already exists")
        } else {
            try await post.save(on: req.db)
            return PostDTO(from: post)
        }
    }
    
    func retrieveCirclePosts(req: Request) async throws -> [PostDTO] {
        let circle = try await getCircle(req: req)
        let user = try await getUser(req: req)
        
        return try await circle.$posts.query(on: req.db).all()
            .map { PostDTO(from: $0)}
    }
    
    func retrieveUserPosts(req: Request) async throws -> [PostDTO] {
        let circle = try await getCircle(req: req)
        let user = try await getUser(req: req)
        
        return try await circle.$posts.query(on: req.db)
            .filter(\.$author.$id == user.id!)
            .all()
            .map { PostDTO(from: $0)}
    }
    
    func retrievePost(req: Request) async throws -> PostDTO {
        let circle = try await getCircle(req: req)
        let post = try await getPost(req: req)
        
        return PostDTO(from: post)
    }
    
    func editPost(req: Request) async throws -> PostDTO {
        func transferFields(_ dto: PostDTO, _ post: Post) {
            post.content = dto.content
        }
        let circle = try await getCircle(req: req)
        let post = try await getPost(req: req)
        
        let dto = try req.content.decode(PostDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(sanitizedDTO, post)
        
        try await post.update(on: req.db)
        
        return PostDTO(from: post)
        
        
    }
    
    func removePost(req: Request) async throws -> Response {
        let circle = try await getCircle(req: req)
        let post = try await getPost(req: req)
        try await post.delete(on: req.db)
        return Response(status: .ok, body: .init(stringLiteral: "Post was removed from the database"))
    }
    
    func postExists(_ post: Post, on db: any Database) async throws -> Bool {
        return try await Post.find(post.id, on: db) != nil
    }
    
    func validateAndSanitize(_ postDTO: PostDTO) throws -> PostDTO {
        try InputValidator.validatePost(postDTO)
        let sanitizedDTO = InputSanitizer.sanitizePost(postDTO)
        return sanitizedDTO
    }
    
}
