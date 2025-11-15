//
//  EventsController.swift
//  tryingVapor
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor

struct EventsController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let events = routes.grouped("circles", ":circleID", "events")
        
        events.get(use: retrieveAll)
        events.post(use: createEvent)
        
        events.group(":eventID") { event in
            event.get(use: retrieve)
//            event.patch(use: edit)
//            event.delete(use: remove)
        }
        
    }
    
    func retrieveAll(req: Request) async throws -> String {
        let circleID = req.parameters.get("circleID")!
        return "These are Circle \(circleID)'s events"
    }
    
    func retrieve(req: Request) async throws -> String {
        let circleID = req.parameters.get("circleID")!
        let eventID = req.parameters.get("eventID")!
        return "Circle \(circleID)'s event ID = \(eventID)"
    }
    
    func createEvent(req: Request) async throws -> String {
        "Create new event"
    }
    
//    func edit(req: Request) async throws -> String {
//
//    }
    
//    func remove(req: Request) async throws -> {
//
//    }
    
}
