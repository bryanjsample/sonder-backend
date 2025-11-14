//
//  EventsController.swift
//  tryingVapor
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor

struct EventsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let events = routes.grouped("circles", ":circleId", "events")
        
        events.get(use: retrieveAll)
        
        events.group(":eventId") { event in
            event.get(use: retrieve)
        }
        
    }
    
    func retrieveAll(req: Request) async throws -> String {
        let circleId = req.parameters.get("circleId")!
        return "These are Circle \(circleId)'s events"
    }
    
    func retrieve(req: Request) async throws -> String {
        let circleId = req.parameters.get("circleId")!
        let eventId = req.parameters.get("eventId")!
        return "Circle \(circleId)'s event id = \(eventId)"
    }
    
}
