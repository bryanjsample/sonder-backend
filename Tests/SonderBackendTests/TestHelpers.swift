//
//  TestHelpers.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/20/25.
//

@testable import SonderBackend
import VaporTesting
import Testing
import Fluent

struct TestHelpers {
    
    // Routes
    let usersRoute = "users"
    let circlesRoute = "circles"
    let postsSegment = "posts"
    let eventsSegment = "events"
    let commentsSegment = "comments"
    
    // Request payloads
    struct CreateUserRequest: Content {
        let email: String
        let firstName: String
        let lastName: String
        let username: String?
        let pictureUrl: String?
    }

    struct CreateCircleRequest: Content {
        let name: String
        let description: String
        let pictureUrl: String?
    }

    struct CreatePostRequest: Content {
        let content: String
    }

    struct CreateEventRequest: Content {
        let host: User
        let circle: Circle
        let title: String
        let description: String
        let startTime: Date
        let endTime: Date
    }
    
    struct CreateCommentRequest: Content {
        let content: String
    }
    
    func createUser(app: Application, email: String) async throws -> User {
        let email = email.lowercased()
        let body = CreateUserRequest(
            email: email,
            firstName: "Circle",
            lastName: "Tester",
            username: "tester_\(UUID().uuidString.prefix(6))",
            pictureUrl: "https://cdn.example.com/avatars/\(UUID().uuidString).png"
        )
        try await app.test(.POST, usersRoute, beforeRequest: { req in
            try req.content.encode(body)
        }, afterResponse: { res in
            #expect(res.status == .ok)
        })
        let user = try await User.query(on: app.db).filter(\.$email == email).first()
        return try #require(user)
    }
    
    func createCircle(app: Application, name: String) async throws -> Circle {
        let body = CreateCircleRequest(
            name: name,
            description: "A valid circle description for \(name)",
            pictureUrl: "https://cdn.example.com/circles/\(UUID().uuidString).png"
        )
        try await app.test(.POST, circlesRoute, beforeRequest: { req in
            try req.content.encode(body)
        }, afterResponse: { res in
            #expect(res.status == .ok)
        })
        let circle = try await Circle.query(on: app.db).filter(\.$name == name).first()
        return try #require(circle)
    }
    
    func createPost(app: Application, circleID: UUID, authorID: UUID, content: String) async throws -> Post {
        let body = CreatePostRequest(content: content)
        try await app.test(.POST, "\(circlesRoute)/\(circleID.uuidString)/\(postsSegment)/user/\(authorID.uuidString)", beforeRequest: { req in
            try req.content.encode(body)
        }, afterResponse: { res in
            #expect(res.status == .ok)
        })
        let post = try await Post.query(on: app.db).filter(\.$content == SonderBackend.InputSanitizer.sanitizeTextBlock(content)).first()
        return try #require(post)
    }

    func createEvent(app: Application, title: String) async throws -> CalendarEvent {
        let start = Date().addingTimeInterval(3600)
        let end = start.addingTimeInterval(7200)
        let body = await CreateEventRequest(
            host: try createUser(app: app, email: "eventhost@gmail.com"),
            circle: try createCircle(app: app, name: "circleowner@gmail.com"),
            title: title,
            description: "Event for circle",
            startTime: start,
            endTime: end
        )
        try await app.test(.POST, "\(circlesRoute)/\(body.circle.id!.uuidString)/\(eventsSegment)/user/\(body.host.id!.uuidString)", beforeRequest: { req in
            try req.content.encode(body)
        }, afterResponse: { res in
            #expect(res.status == .ok)
        })
        let evt = try await CalendarEvent.query(on: app.db).filter(\.$title == title).first()
        return try #require(evt)
    }
    
    func createComment(app: Application, circleID: UUID, postID: UUID, authorID: UUID, content: String) async throws -> SonderBackend.Comment {
        let body = CreateCommentRequest(content: content)
        try await app.test(.POST, "\(circlesRoute)/\(circleID.uuidString)/\(postsSegment)/\(postID.uuidString)/\(commentsSegment)/user/\(authorID.uuidString)", beforeRequest: { req in
            try req.content.encode(body)
        }, afterResponse: { res in
            #expect(res.status == .ok)
        })
        let comment = try await SonderBackend.Comment.query(on: app.db).filter(\.$content == content).first()
        return try #require(comment)
    }

}
