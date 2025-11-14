//
//  GroupsController.swift
//  tryingVapor
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor

struct CirclesController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let circles = routes.grouped("circles")
        
        circles.get(use: retrieveAll)
        circles.post(use: createCircle)
        
        circles.group(":circleId") { circle in
            circle.get(use: retrieve)
        }
    }
    
    func retrieveAll(req: Request) async throws -> String {
        "Circles Homepage"
    }
    
    func createCircle(req: Request) async throws -> String {
        "Create a new circle"
    }
    
    func retrieve(req: Request) async throws -> String {
        let circleId = req.parameters.get("circleId")!
        return "Circle id = \(circleId)"
    }
}
