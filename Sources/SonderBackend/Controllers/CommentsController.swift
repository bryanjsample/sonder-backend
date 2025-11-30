//
//  CommentsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor
import Fluent

struct CommentsController: RouteCollection {
    
    // NEED TO AUTHORIZE EACH ENDPOINT
    // NEED TO CHECK VALIDITY OF CIRCLE USER RELATION
    
    let helper = ControllerHelper()
    
    func boot(routes: any RoutesBuilder) throws {
        let commentsProtected = routes.grouped("circles", ":circleID", "posts", ":postID", "comments").grouped(UserToken.authenticator())
        
        commentsProtected.get(use: retrieveAll)
        commentsProtected.post(use: createComment)
        
        commentsProtected.group(":commentID") { comment in
            comment.get(use: retrieve)
            comment.patch(use: edit)
            comment.delete(use: remove)
        }
    }
    
    func retrieveAll(req: Request) async throws ->  [CommentDTO] {
        // authenticate user on request
        let _ = try req.auth.require(User.self)
        
        // confirm circle exists -- may be more efficient to send back boolean rather than object
        let _ = try await helper.getCircle(req: req)
        // confirm post exists -- may be more efficient to send back boolean rather than object
        let post = try await helper.getPost(req: req)
        
        return try await post.$comments.query(on: req.db)
            .all()
            .map { CommentDTO(from: $0) }
    }
    
    func createComment(req: Request) async throws -> CommentDTO {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        
        // confirm circle exists -- may be more efficient to send back boolean rather than object
        let _ = try await helper.getCircle(req: req)
        // confirm post exists -- may be more efficient to send back boolean rather than object
        let post = try await helper.getPost(req: req)
        
        var commentDTO = try req.content.decode(CommentDTO.self)
        commentDTO.postID = post.id!
        commentDTO.authorID = user.id!
        let sanitizedDTO = try commentDTO.validateAndSanitize()
        let comment = sanitizedDTO.toModel()
        if try await comment.exists(on: req.db) {
            throw Abort(.badRequest, reason: "Comment already exists")
        } else {
            try await comment.save(on: req.db)
            return CommentDTO(from: comment)
        }
    }
    
    func retrieve(req: Request) async throws -> CommentDTO {
        // authenticate user on request
        let _ = try req.auth.require(User.self)
        
        // confirm circle exists -- may be more efficient to send back boolean rather than object
        let _ = try await helper.getCircle(req: req)
        // confirm post exists -- may be more efficient to send back boolean rather than object
        let _ = try await helper.getPost(req: req)
        
        let comment = try await helper.getComment(req: req)
        return CommentDTO(from: comment)
    }
    
    func edit(req: Request) async throws -> CommentDTO {
        func transferFields(_ dto: CommentDTO, comment: Comment) {
            comment.content = dto.content
        }
        // authenticate user on request -- CONFIRM THAT CLIENT REQUEST IS COMMENT OWNER
        let _ = try req.auth.require(User.self)
        
        // confirm circle exists -- may be more efficient to send back boolean rather than object
        let _ = try await helper.getCircle(req: req)
        // confirm post exists -- may be more efficient to send back boolean rather than object
        let _ = try await helper.getPost(req: req)
        
        let comment = try await helper.getComment(req: req)
        let dto = try req.content.decode(CommentDTO.self)
        let sanitizedDTO = try dto.validateAndSanitize()
        transferFields(sanitizedDTO, comment: comment)
        try await comment.update(on: req.db)
        return CommentDTO(from: comment)
    }
    
    func remove(req: Request) async throws -> Response {
        // authenticate user on request -- CONFIRM THAT CLIENT REQUEST IS COMMENT OWNER
        let _ = try req.auth.require(User.self)
        
        // confirm circle exists -- may be more efficient to send back boolean rather than object
        let _ = try await helper.getCircle(req: req)
        // confirm post exists -- may be more efficient to send back boolean rather than object
        let _ = try await helper.getPost(req: req)
        
        let comment = try await helper.getComment(req: req)
        try await comment.delete(on: req.db)
        return Response(status: .ok, body: .init(stringLiteral: "Comment was removed from the database"))
    }
    


    
}
