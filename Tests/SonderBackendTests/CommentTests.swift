//
//  CommentTests.swift
//  SonderBackend
//
//  Created by Test Generator on 11/20/25.
//

import Fluent
import Testing
import VaporTesting

@testable import SonderBackend

@Suite("Comment Endpoint Tests", .serialized)
struct CommentTests {

    let helper = TestHelpers()

    private func withApp(_ test: (Application) async throws -> Void)
        async throws
    {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }

    @Test(
        "POST /circles/:circleID/posts/:postID/comments/user/:userID - Create Comment"
    )
    func testCreateComment() async throws {
        try await withApp { app in
            let email = "commenter_\(UUID().uuidString)@example.com"
            let circleName = "CommentsCircle_\(UUID().uuidString.prefix(8))"
            let postContent = "Post for comments \(UUID().uuidString)"
            let commentContent = "Nice post! \(UUID().uuidString)"

            let user = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(
                app: app,
                name: circleName
            )
            let post = try await helper.createPost(
                app: app,
                circleID: try #require(circle.id),
                authorID: try #require(user.id),
                content: postContent
            )

            _ = try await helper.createComment(
                app: app,
                circleID: try #require(circle.id),
                postID: try #require(post.id),
                authorID: try #require(user.id),
                content: commentContent
            )
        }
    }

    @Test(
        "GET /circles/:circleID/posts/:postID/comments - Retrieve All Comments"
    )
    func testRetrieveAllComments() async throws {
        try await withApp { app in
            let email = "commenter_\(UUID().uuidString)@example.com"
            let circleName = "CommentsCircle_\(UUID().uuidString.prefix(8))"
            let postContent = "Post to list comments \(UUID().uuidString)"
            let commentContent = "First comment \(UUID().uuidString)"

            let user = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(
                app: app,
                name: circleName
            )
            let post = try await helper.createPost(
                app: app,
                circleID: try #require(circle.id),
                authorID: try #require(user.id),
                content: postContent
            )
            _ = try await helper.createComment(
                app: app,
                circleID: try #require(circle.id),
                postID: try #require(post.id),
                authorID: try #require(user.id),
                content: commentContent
            )

            try await app.test(
                .GET,
                "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)/\(helper.commentsSegment)",
                afterResponse: { res in
                    #expect(res.status == .ok)
                }
            )
        }
    }

    @Test(
        "GET /circles/:circleID/posts/:postID/comments/:commentID - Retrieve Comment"
    )
    func testRetrieveComment() async throws {
        try await withApp { app in
            let email = "commenter_\(UUID().uuidString)@example.com"
            let circleName = "CommentsCircle_\(UUID().uuidString.prefix(8))"
            let postContent = "Post to get comment \(UUID().uuidString)"
            let commentContent = "Get me \(UUID().uuidString)"

            let user = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(
                app: app,
                name: circleName
            )
            let post = try await helper.createPost(
                app: app,
                circleID: try #require(circle.id),
                authorID: try #require(user.id),
                content: postContent
            )
            let comment = try await helper.createComment(
                app: app,
                circleID: try #require(circle.id),
                postID: try #require(post.id),
                authorID: try #require(user.id),
                content: commentContent
            )

            try await app.test(
                .GET,
                "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)/\(helper.commentsSegment)/\(try #require(comment.id).uuidString)",
                afterResponse: { res in
                    #expect(res.status == .ok)
                }
            )
        }
    }

    @Test(
        "PATCH /circles/:circleID/posts/:postID/comments/:commentID - Edit Comment"
    )
    func testEditComment() async throws {
        try await withApp { app in
            let email = "commenter_\(UUID().uuidString)@example.com"
            let circleName = "CommentsCircle_\(UUID().uuidString.prefix(8))"
            let postContent = "Post for edit \(UUID().uuidString)"
            let commentContent = "Original \(UUID().uuidString)"

            let user = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(
                app: app,
                name: circleName
            )
            let post = try await helper.createPost(
                app: app,
                circleID: try #require(circle.id),
                authorID: try #require(user.id),
                content: postContent
            )
            let comment = try await helper.createComment(
                app: app,
                circleID: try #require(circle.id),
                postID: try #require(post.id),
                authorID: try #require(user.id),
                content: commentContent
            )

            // Fetch DTO then modify for PATCH
            var dto = try await app.getResponse(
                method: .GET,
                path:
                    "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)/\(helper.commentsSegment)/\(try #require(comment.id).uuidString)",
                as: CommentDTO.self
            )
            dto.content = commentContent + " (edited)"

            try await app.test(
                .PATCH,
                "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)/\(helper.commentsSegment)/\(try #require(comment.id).uuidString)",
                beforeRequest: { req in
                    try req.content.encode(dto)
                },
                afterResponse: { res in
                    #expect(res.status == .ok)
                }
            )
        }
    }

    @Test(
        "DELETE /circles/:circleID/posts/:postID/comments/:commentID - Remove Comment"
    )
    func testRemoveComment() async throws {
        try await withApp { app in
            let email = "commenter_\(UUID().uuidString)@example.com"
            let circleName = "CommentsCircle_\(UUID().uuidString.prefix(8))"
            let postContent = "Post for delete \(UUID().uuidString)"
            let commentContent = "Delete me \(UUID().uuidString)"

            let user = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(
                app: app,
                name: circleName
            )
            let post = try await helper.createPost(
                app: app,
                circleID: try #require(circle.id),
                authorID: try #require(user.id),
                content: postContent
            )
            let comment = try await helper.createComment(
                app: app,
                circleID: try #require(circle.id),
                postID: try #require(post.id),
                authorID: try #require(user.id),
                content: commentContent
            )

            try await app.test(
                .DELETE,
                "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)/\(helper.commentsSegment)/\(try #require(comment.id).uuidString)",
                afterResponse: { res in
                    #expect(res.status == .ok)
                }
            )
        }
    }
}

extension Application {
    fileprivate func getResponse<T: Decodable>(
        method: HTTPMethod,
        path: String,
        as type: T.Type
    ) async throws -> T {
        var decoded: T!
        try await self.test(
            method,
            path,
            afterResponse: { res in
                #expect(res.status == .ok)
                decoded = try res.content.decode(T.self)
            }
        )
        return decoded
    }
}
