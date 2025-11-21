//
//  CommentsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor
import Fluent

struct CommentsController: RouteCollection {
    
    let helper = ControllerHelper()
    
    func boot(routes: any RoutesBuilder) throws {
        let comments = routes.grouped("circles", ":circleID", "posts", ":postID", "comments")
        
        comments.get(use: retrieveAll)
        
        comments.group(":commentID") { comment in
            comment.get(use: retrieve)
            comment.patch(use: edit)
            comment.delete(use: remove)
        }
        
        comments.group("user", ":userID") { userComments in
            userComments.post(use: createComment)
        }
    }
    
    func retrieveAll(req: Request) async throws ->  [CommentDTO] {
        let _ = try await helper.getCircle(req: req)
        let post = try await helper.getPost(req: req)
        
        return try await post.$comments.query(on: req.db)
            .all()
            .map { CommentDTO(from: $0) }
    }
    
    func retrieve(req: Request) async throws -> CommentDTO {
        let _ = try await helper.getCircle(req: req)
        let _ = try await helper.getPost(req: req)
        let comment = try await helper.getComment(req: req)
        
        return CommentDTO(from: comment)
    }
    
    func createComment(req: Request) async throws -> CommentDTO {
        let _ = try await helper.getCircle(req: req)
        let post = try await helper.getPost(req: req)
        let user = try await helper.getUser(req: req)
        
        var commentDTO = try req.content.decode(CommentDTO.self)
        
        commentDTO.post = post
        commentDTO.author = user
        
        let sanitizedDTO = try validateAndSanitize(commentDTO)
        let comment = sanitizedDTO.toModel()
        
        if try await commentExists(comment, on: req.db) {
            throw Abort(.badRequest, reason: "Comment already exists")
        } else {
            try await comment.save(on: req.db)
            return CommentDTO(from: comment)
        }
    }
    
    func edit(req: Request) async throws -> CommentDTO {
        func transferFields(_ dto: CommentDTO, comment: Comment) {
            comment.content = dto.content
        }
        let _ = try await helper.getCircle(req: req)
        let _ = try await helper.getPost(req: req)
        let comment = try await helper.getComment(req: req)
        
        let dto = try req.content.decode(CommentDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(sanitizedDTO, comment: comment)
        
        try await comment.update(on: req.db)
        
        return CommentDTO(from: comment)
    }
    
    func remove(req: Request) async throws -> Response {
        let _ = try await helper.getCircle(req: req)
        let _ = try await helper.getPost(req: req)
        let comment = try await helper.getComment(req: req)
        try await comment.delete(on: req.db)
        return Response(status: .ok, body: .init(stringLiteral: "Comment was removed from the database"))
    }
    
    func commentExists(_ comment: Comment, on db: any Database) async throws -> Bool {
        return try await Comment.find(comment.id, on: db) != nil
    }
    
    func validateAndSanitize(_ commentDTO: CommentDTO) throws -> CommentDTO {
        try InputValidator.validateComment(commentDTO)
        let sanitizedDTO = InputSanitizer.sanitizeComment(commentDTO)
        return sanitizedDTO
    }
    
}
