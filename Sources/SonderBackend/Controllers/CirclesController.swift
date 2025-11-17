//
//  GroupsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor

struct CirclesController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let circles = routes.grouped("circles")
        
        circles.get(use: retrieveAll)
        circles.post(use: createCircle)
        
        circles.group(":circleID") { circle in
            circle.get(use: retrieve)
//            circle.patch(use: edit)
//            circle.delete(use: remove)
        }
    }
    
    func retrieveAll(req: Request) async throws -> String {
        "Circles Homepage"
    }
    
    func createCircle(req: Request) async throws -> String {
        "Create a new circle"
        
    }
    
    func retrieve(req: Request) async throws -> String {
        let circleID = req.parameters.get("circleID")!
        return "Circle ID = \(circleID)"
    }
    
//    func edit(req: Request) async throws -> String {
//
//    }
    
//    func remove(req: Request) async throws -> {
//
//    }
}
