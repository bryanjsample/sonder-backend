//
//  PostTests.swift
//  SonderBackend
//
//  Created by Test Generator on 11/20/25.
//

@testable import SonderBackend
import VaporTesting
import Testing
import Fluent

@Suite("Post Endpoint Tests", .serialized)
struct PostTests {
    
    let helper = TestHelpers()
    
    private func withApp(_ test: (Application) async throws -> ()) async throws {
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

    @Test("POST /circles/:circleID/posts/user/:userID - Create Post")
    func testCreatePost() async throws {
        try await withApp { app in
            let email = "author_\(UUID().uuidString)@example.com"
            let circleName = "PostsCircle_\(UUID().uuidString.prefix(8))"
            let content = "Hello Circle! \(UUID().uuidString)"

            let author = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(app: app, name: circleName)

            _ = try await helper.createPost(
                app: app,
                circleID: try #require(circle.id),
                authorID: try #require(author.id),
                content: content
            )
        }
    }

    @Test("GET /circles/:circleID/posts - Retrieve Circle Posts")
    func testRetrieveCirclePosts() async throws {
        try await withApp { app in
            let email = "author_\(UUID().uuidString)@example.com"
            let circleName = "PostsCircle_\(UUID().uuidString.prefix(8))"
            let content = "Initial Post \(UUID().uuidString)"

            let author = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(app: app, name: circleName)
            _ = try await helper.createPost(app: app, circleID: try #require(circle.id), authorID: try #require(author.id), content: content)

            try await app.test(.GET, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("GET /circles/:circleID/posts/user/:userID - Retrieve User Posts in Circle")
    func testRetrieveUserPosts() async throws {
        try await withApp { app in
            let email = "author_\(UUID().uuidString)@example.com"
            let circleName = "PostsCircle_\(UUID().uuidString.prefix(8))"
            let content = "User Post \(UUID().uuidString)"

            let author = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(app: app, name: circleName)
            _ = try await helper.createPost(app: app, circleID: try #require(circle.id), authorID: try #require(author.id), content: content)

            try await app.test(.GET, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/user/\(try #require(author.id).uuidString)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("GET /circles/:circleID/posts/:postID - Retrieve Post")
    func testRetrievePost() async throws {
        try await withApp { app in
            let email = "author_\(UUID().uuidString)@example.com"
            let circleName = "PostsCircle_\(UUID().uuidString.prefix(8))"
            let content = "Get Me \(UUID().uuidString)"

            let author = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(app: app, name: circleName)
            let post = try await helper.createPost(app: app, circleID: try #require(circle.id), authorID: try #require(author.id), content: content)

            try await app.test(.GET, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("PATCH /circles/:circleID/posts/:postID - Edit Post")
    func testEditPost() async throws {
        try await withApp { app in
            let email = "author_\(UUID().uuidString)@example.com"
            let circleName = "PostsCircle_\(UUID().uuidString.prefix(8))"
            let content = "Original \(UUID().uuidString)"

            let author = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(app: app, name: circleName)
            let post = try await helper.createPost(app: app, circleID: try #require(circle.id), authorID: try #require(author.id), content: content)

            // Fetch DTO then modify content for PATCH (safer if DTO has required fields)
            var dto = try await app.getResponse(
                method: .GET,
                path: "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)",
                as: PostDTO.self
            )
            dto.content = content + " (edited)"

            try await app.test(.PATCH, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)", beforeRequest: { req in
                try req.content.encode(dto)
            }, afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }

    @Test("DELETE /circles/:circleID/posts/:postID - Remove Post")
    func testRemovePost() async throws {
        try await withApp { app in
            let email = "author_\(UUID().uuidString)@example.com"
            let circleName = "PostsCircle_\(UUID().uuidString.prefix(8))"
            let content = "Delete Me \(UUID().uuidString)"

            let author = try await helper.createUser(app: app, email: email)
            let circle = try await helper.createCircle(app: app, name: circleName)
            let post = try await helper.createPost(app: app, circleID: try #require(circle.id), authorID: try #require(author.id), content: content)

            try await app.test(.DELETE, "\(helper.circlesRoute)/\(try #require(circle.id).uuidString)/\(helper.postsSegment)/\(try #require(post.id).uuidString)", afterResponse: { res in
                #expect(res.status == .ok)
            })
        }
    }
}

private extension Application {
    // Small helper to GET and decode a DTO in tests
    func getResponse<T: Decodable>(method: HTTPMethod, path: String, as type: T.Type) async throws -> T {
        var decoded: T!
        try await self.test(method, path, afterResponse: { res in
            #expect(res.status == .ok)
            decoded = try res.content.decode(T.self)
        })
        return decoded
    }
}
