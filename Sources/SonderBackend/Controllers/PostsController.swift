//
//  PostsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Fluent
import SonderDTOs
import Vapor

struct PostsController: RouteCollection {

    // NEED TO AUTHORIZE ALL ENDPOINTS
    // NEED TO ENSURE USER IS IN GROUP BEFORE RETURNING POSTS

    let helper = ControllerHelper()

    func boot(routes: any RoutesBuilder) throws {
        let postsProtected = routes.grouped("circles", ":circleID", "posts")
            .grouped(AccessToken.authenticator())

        postsProtected.get(use: retrieveCirclePosts)
        postsProtected.post(use: createPost)

        postsProtected.group(":postID") { post in
            post.get(use: retrievePost)
            post.patch(use: editPost)
            post.delete(use: removePost)
        }
    }

    func retrieveCirclePosts(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }

        let posts = try await circle.$posts.query(on: req.db).all()
        
        var postDTOs: [PostDTO] = []
        for post in posts {
            let author = try await post.$author.get(on: req.db)
            let authorDTO = UserDTO(from: author)
            postDTOs.append(PostDTO(from: post, author: authorDTO))
        }
        
        let sorted = postDTOs.sorted {
            $0.createdAt! > $1.createdAt!
        }
        
        return try helper.sendResponseObject(dto: sorted)
    }

    func createPost(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }

        var postDTO = try req.content.decode(PostDTO.self)

        postDTO.circleID = circle.id!
        postDTO.authorID = user.id!
        postDTO.author = UserDTO(from: user)

        let sanitizedDTO = try postDTO.validateAndSanitize()
        let post = sanitizedDTO.toModel()

        if try await post.exists(on: req.db) {
            throw Abort(.conflict, reason: "Post already exists")
        } else {
            try await post.save(on: req.db)
            let dto = PostDTO(from: post)
            return try helper.sendResponseObject(dto: dto, responseStatus: .created)
        }
    }

    func retrievePost(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }
        let post = try await helper.getPost(req: req)

        let dto = PostDTO(from: post)
        return try helper.sendResponseObject(dto: dto)
    }

    func editPost(req: Request) async throws -> Response {
        func transferFields(_ dto: PostDTO, _ post: Post) {
            post.content = dto.content
        }
        // authenticate user on request -- ENSURE CLIENT IS COMMENT AUTHOR
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }
        
        let post = try await helper.getPost(req: req)
        
        if !user.isPostAuthor(post) {
            throw Abort(.unauthorized, reason: "User is not the author of requested post.")
        }

        let dto = try req.content.decode(PostDTO.self)
        let sanitizedDTO = try dto.validateAndSanitize()

        transferFields(sanitizedDTO, post)

        try await post.update(on: req.db)

        let resDTO = PostDTO(from: post)
        return try helper.sendResponseObject(dto: resDTO)

    }

    func removePost(req: Request) async throws -> Response {
        // authenticate user on request -- ENSURE CLIENT IS COMMENT AUTHOR
        let user = try req.auth.require(User.self)
        let circle = try await helper.getCircle(req: req)
        
        if !user.isCircleMember(circle) {
            throw Abort(.unauthorized, reason: "User is not a member of requested circle.")
        }
        
        let post = try await helper.getPost(req: req)
        
        if !user.isPostAuthor(post) {
            throw Abort(.unauthorized, reason: "User is not the author of requested post.")
        }
        
        try await post.delete(on: req.db)
        return Response(
            status: .ok,
            body: .init(stringLiteral: "Post was removed from the database")
        )
    }

}

extension PostDTO {
    init(from post: Post, author: UserDTO? = nil) {
        self.init(
            id: post.id ?? nil,
            circleID: post.$circle.id,
            authorID: post.$author.id,
            author: author,
            content: post.content,
            createdAt: post.createdAt ?? nil
        )
    }

    func toModel() -> Post {
        let model = Post()
        model.id = self.id
        model.$circle.id = self.circleID
        model.$author.id = self.authorID
        model.content = self.content
        model.createdAt = self.createdAt
        return model
    }
}
