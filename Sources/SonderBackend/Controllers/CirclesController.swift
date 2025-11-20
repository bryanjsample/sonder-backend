//
//  GroupsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor
import Fluent

struct CirclesController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let circles = routes.grouped("circles")

        circles.post(use: createCircle)
        
        circles.group(":circleID") { circle in
            circle.get(use: retrieve)
            circle.patch(use: edit)
            circle.delete(use: remove)
        }
    }
    
    func createCircle(req: Request) async throws -> Response {
        let dto = try req.content.decode(CircleDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        let circle = sanitizedDTO.toModel()
        
        if try await circleExists(circle, on: req.db) {
            throw Abort(.badRequest, reason: "Circle already exists")
        } else {
            try await circle.save(on: req.db)
            let dto = CircleDTO(from: circle)
            return Response(status: .created, body: .init(data: try JSONEncoder().encode(dto)))
        }
    }
    
    func retrieve(req: Request) async throws -> Response {
        let circleIDParam = try req.parameters.require("circleID")
        // let circleID = sanitizeandvalidate(circleIDParam)
        guard let circleUUID = UUID(uuidString: circleIDParam) else {
            throw Abort(.notFound, reason: "Invalid circle ID")
        }
        guard let circle = try await Circle.find(circleUUID, on: req.db) else {
            throw Abort(.notFound, reason: "Circle does not exist")
        }
        let dto = CircleDTO(from: circle)
        return Response(status: .ok, body: .init(data: try JSONEncoder().encode(dto)))
    }
    
    func edit(req: Request) async throws -> Response {
        func transferFields(_ dto: CircleDTO, _ circle: Circle) {
            circle.name = dto.name
            circle.description = dto.description
            if let picureUrl = dto.pictureUrl {
                circle.pictureUrl = picureUrl
            }
        }
        let circleIDParam = try req.parameters.require("circleID")
        // let circleID = sanititzeandvalidate(param)
        guard let circleUUID = UUID(uuidString: circleIDParam) else {
            throw Abort(.badRequest, reason: "Invalid circle ID")
        }
        guard let circle = try await Circle.find(circleUUID, on: req.db) else {
            throw Abort(.notFound, reason: "Circle does not exist")
        }
        let dto = try req.content.decode(CircleDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(sanitizedDTO, circle)
        
        if try await circleExists(circle, on: req.db) {
            try await circle.update(on: req.db)
        } else {
            throw Abort(.notFound, reason: "Circle does not exist")
        }
        
        let responseDTO = CircleDTO(from: circle)
        return Response(status: .ok, body: .init(data: try JSONEncoder().encode(responseDTO)))
    }
    
    func remove(req: Request) async throws -> Response {
        let circleIDParam = try req.parameters.require("circleID")
        // let circleID = sanititzeandvalidate(param)
        guard let circleUUID = UUID(uuidString: circleIDParam) else {
            throw Abort(.badRequest, reason: "Invalid circle ID")
        }
        guard let circle = try await Circle.find(circleUUID, on: req.db) else {
            throw Abort(.notFound, reason: "Circle does not exist")
        }
        if try await circleExists(circle, on: req.db) {
            try await circle.delete(on: req.db)
        } else {
            throw Abort(.notFound, reason: "Circle does not exist")
        }
        return Response(status: .ok, body: .init(stringLiteral: "Circle was removed from database"))
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
