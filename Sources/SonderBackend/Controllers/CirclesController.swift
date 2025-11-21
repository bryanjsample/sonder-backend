//
//  GroupsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor
import Fluent

struct CirclesController: RouteCollection {
    
    let helper = ControllerHelper()
    
    func boot(routes: any RoutesBuilder) throws {
        let circles = routes.grouped("circles")

        circles.post(use: createCircle)
        
        circles.group(":circleID") { circle in
            circle.get(use: retrieve)
            circle.patch(use: edit)
            circle.delete(use: remove)
        }
        
        circles.group(":circleID","users") { circleUsers in
            circleUsers.get(use: retrieveUsers)
        }
        
        circles.group(":circleID","feed") { circleFeed in
            circleFeed.get(use: retrieveFeed)
        }
    }
    
    func createCircle(req: Request) async throws -> CircleDTO {
        let dto = try req.content.decode(CircleDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        let circle = sanitizedDTO.toModel()
        
        if try await circleExists(circle, on: req.db) {
            throw Abort(.badRequest, reason: "Circle already exists")
        } else {
            try await circle.save(on: req.db)
            return CircleDTO(from: circle)
        }
    }
    
    func retrieve(req: Request) async throws -> CircleDTO {
        let circle = try await helper.getCircle(req: req)
        return CircleDTO(from: circle)
    }
    
    func edit(req: Request) async throws -> CircleDTO {
        func transferFields(_ dto: CircleDTO, _ circle: Circle) {
            circle.name = dto.name
            circle.description = dto.description
            if let picureUrl = dto.pictureUrl {
                circle.pictureUrl = picureUrl
            }
        }
        let circle = try await helper.getCircle(req: req)
        
        let dto = try req.content.decode(CircleDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(sanitizedDTO, circle)

        try await circle.update(on: req.db)

        return CircleDTO(from: circle)
    }
    
    func remove(req: Request) async throws -> Response {
        let circle = try await helper.getCircle(req: req)
        try await circle.delete(on: req.db)
        return Response(status: .ok, body: .init(stringLiteral: "Circle was removed from database"))
    }
    
    func retrieveUsers(req: Request) async throws  -> [UserDTO] {
        let circle = try await helper.getCircle(req: req)
        
        return try await circle.$users.query(on: req.db).all()
            .map { UserDTO(from: $0) }
    }
    
    func retrieveFeed(req: Request) async throws -> FeedResponseDTO {
        let circle = try await helper.getCircle(req: req)

        // ADD IN PAGINATION FUNCTIONALITY
        
        let posts = try await Post.query(on: req.db)
            .filter(\.$circle.$id == circle.id!)
            .with(\.$circle)
            .with(\.$author)
            .all()
        
        let events = try await CalendarEvent.query(on: req.db)
            .filter(\.$circle.$id == circle.id!)
            .with(\.$circle)
            .with(\.$host)
            .all()

        let postDTOs = posts.map { FeedItemDTO.post(PostDTO(from: $0)) }
        let eventDTOs = events.map { FeedItemDTO.event(CalendarEventDTO(from: $0)) }
        let merged = (postDTOs + eventDTOs).sorted { $0.createdAt! > $1.createdAt! }

        return FeedResponseDTO(items: merged)
    }
    
    func circleExists(_ circle: Circle, on db: any Database) async throws -> Bool {
        return try await Circle.find(circle.id, on: db) != nil
    }
    
    func validateAndSanitize(_ circleDTO: CircleDTO) throws -> CircleDTO {
        try InputValidator.validateCircle(circleDTO)
        let sanitizedDTO = InputSanitizer.sanitizeCircle(circleDTO)
        return sanitizedDTO
    }
}

