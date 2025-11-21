//
//  PostsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor
import Fluent

struct PostsController: RouteCollection {
    
    let helper = ControllerHelper()
    
    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("circles", ":circleID", "posts")
        
        posts.get(use: retrieveCirclePosts)
        
        posts.group(":postID") { post in
            post.get(use: retrievePost)
            post.patch(use: editPost)
            post.delete(use: removePost)
        }
        
        posts.group("user", ":userID") { userPosts in
            userPosts.post(use: createPost)
            userPosts.get(use: retrieveUserPosts)
        }
    }

    
    func retrieveCirclePosts(req: Request) async throws -> [PostDTO] {
        let circle = try await helper.getCircle(req: req)
        
        return try await circle.$posts.query(on: req.db)
            .all()
            .map { PostDTO(from: $0)}
    }
    
    func retrieveUserPosts(req: Request) async throws -> [PostDTO] {
        let circle = try await helper.getCircle(req: req)
        let user = try await helper.getUser(req: req)
        
        return try await circle.$posts.query(on: req.db)
            .filter(\.$author.$id == user.id!)
            .all()
            .map { PostDTO(from: $0)}
    }
    
    func retrievePost(req: Request) async throws -> PostDTO {
        let _ = try await helper.getCircle(req: req)
        let post = try await helper.getPost(req: req)
        
        return PostDTO(from: post)
    }
    
    func createPost(req: Request) async throws -> PostDTO {
        let circle = try await helper.getCircle(req: req)
        let user = try await helper.getUser(req: req)
        
        var postDTO = try req.content.decode(PostDTO.self)
        
        postDTO.circleID = circle.id!
        postDTO.authorID = user.id!
        
        let sanitizedDTO = try validateAndSanitize(postDTO)
        let post = sanitizedDTO.toModel()
        
        if try await postExists(post, on: req.db) {
            throw Abort(.badRequest, reason: "Post already exists")
        } else {
            try await post.save(on: req.db)
            return PostDTO(from: post)
        }
    }
    
    func editPost(req: Request) async throws -> PostDTO {
        func transferFields(_ dto: PostDTO, _ post: Post) {
            post.content = dto.content
        }
        let _ = try await helper.getCircle(req: req)
        let post = try await helper.getPost(req: req)
        
        let dto = try req.content.decode(PostDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(sanitizedDTO, post)
        
        try await post.update(on: req.db)
        
        return PostDTO(from: post)
        
        
    }
    
    func removePost(req: Request) async throws -> Response {
        let _ = try await helper.getCircle(req: req)
        let post = try await helper.getPost(req: req)
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
