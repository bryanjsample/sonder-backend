//
//  PostsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor
import Fluent

struct PostsController: RouteCollection {
    
    // NEED TO AUTHORIZE ALL ENDPOINTS
    // NEED TO ENSURE USER IS IN GROUP BEFORE RETURNING POSTS
    
    let helper = ControllerHelper()
    
    func boot(routes: any RoutesBuilder) throws {
        let postsProtected = routes.grouped("circles", ":circleID", "posts").grouped(UserToken.authenticator())
        
        postsProtected.get(use: retrieveCirclePosts)
        postsProtected.post(use: createPost)
        
        postsProtected.group(":postID") { post in
            post.get(use: retrievePost)
            post.patch(use: editPost)
            post.delete(use: removePost)
        }
    }

    
    func retrieveCirclePosts(req: Request) async throws -> [PostDTO] {
        // authenticate user on request
        let _ = try req.auth.require(User.self)
        
        let circle = try await helper.getCircle(req: req)
        
        return try await circle.$posts.query(on: req.db)
            .all()
            .map { PostDTO(from: $0)}
    }
    
    func createPost(req: Request) async throws -> PostDTO {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        
        let circle = try await helper.getCircle(req: req)
        
        var postDTO = try req.content.decode(PostDTO.self)
        
        postDTO.circleID = circle.id!
        postDTO.authorID = user.id!
        
        let sanitizedDTO = try postDTO.validateAndSanitize()
        let post = sanitizedDTO.toModel()
        
        if try await post.exists(on: req.db) {
            throw Abort(.badRequest, reason: "Post already exists")
        } else {
            try await post.save(on: req.db)
            return PostDTO(from: post)
        }
    }
    
    func retrievePost(req: Request) async throws -> PostDTO {
        // authenticate user on request
        let _ = try req.auth.require(User.self)
        
        let _ = try await helper.getCircle(req: req)
        let post = try await helper.getPost(req: req)
        
        return PostDTO(from: post)
    }
    
    func editPost(req: Request) async throws -> PostDTO {
        func transferFields(_ dto: PostDTO, _ post: Post) {
            post.content = dto.content
        }
        // authenticate user on request -- ENSURE CLIENT IS COMMENT AUTHOR
        let _ = try req.auth.require(User.self)
        
        
        let _ = try await helper.getCircle(req: req)
        let post = try await helper.getPost(req: req)
        
        let dto = try req.content.decode(PostDTO.self)
        let sanitizedDTO = try dto.validateAndSanitize()
        
        transferFields(sanitizedDTO, post)
        
        try await post.update(on: req.db)
        
        return PostDTO(from: post)
        
        
    }
    
    func removePost(req: Request) async throws -> Response {
        // authenticate user on request -- ENSURE CLIENT IS COMMENT AUTHOR
        let _ = try req.auth.require(User.self)
        
        let _ = try await helper.getCircle(req: req)
        let post = try await helper.getPost(req: req)
        try await post.delete(on: req.db)
        return Response(status: .ok, body: .init(stringLiteral: "Post was removed from the database"))
    }

}
