//
//  CalendarEventsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Vapor
import Fluent

struct CalendarEventsController: RouteCollection {
    
    // AUTHORIZE ALL ENDPOINTS
    // VALIDATE USER CIRCLE RELATION
    
    let helper = ControllerHelper()
    
    func boot(routes: any RoutesBuilder) throws {
        let events = routes.grouped("circles", ":circleID", "events")
        
        events.get(use: retrieveCircleEvents)
        
        events.group(":eventID") { event in
            event.get(use: retrieveEvent)
            event.patch(use: editEvent)
            event.delete(use: removeEvent)
        }
        
        events.group("user", ":userID") { userEvents in
            userEvents.post(use: createEvent)
            userEvents.get(use: retrieveUserEvents)
        }
        
    }
    
    func retrieveCircleEvents(req: Request) async throws -> [CalendarEventDTO] {
        let circle = try await helper.getCircle(req: req)
        
        return try await circle.$events.query(on: req.db)
            .all()
            .map { CalendarEventDTO(from: $0) }
    }
    
    func retrieveUserEvents(req: Request) async throws -> [CalendarEventDTO] {
        let circle = try await helper.getCircle(req: req)
        let user = try await helper.getUser(req: req)
        
        return try await circle.$events.query(on: req.db)
            .filter(\.$host.$id == user.id!)
            .all()
            .map { CalendarEventDTO(from: $0) }
    }
    
    func retrieveEvent(req: Request) async throws -> CalendarEventDTO {
        let _ = try await helper.getCircle(req: req)
        let calendarEvent = try await helper.getCalendarEvent(req: req)
        
        return CalendarEventDTO(from: calendarEvent)
    }
    
    func createEvent(req: Request) async throws -> CalendarEventDTO {
        let user = try await helper.getUser(req: req)
        let circle = try await helper.getCircle(req: req)
        var eventDTO = try req.content.decode(CalendarEventDTO.self)
        
        eventDTO.hostID = user.id!
        eventDTO.circleID = circle.id!
        
        let sanitizedDTO = try validateAndSanitize(eventDTO)
        let calendarEvent = sanitizedDTO.toModel()
        
        if try await eventExists(calendarEvent, on: req.db) {
            throw Abort(.badRequest, reason: "Event already exists")
        } else {
            try await calendarEvent.save(on: req.db)
            return CalendarEventDTO(from: calendarEvent)
        }
    }
    
    func editEvent(req: Request) async throws -> CalendarEventDTO {
        func transferFields(_ dto: CalendarEventDTO, event: CalendarEvent) {
            event.$host.id = dto.hostID
            event.$circle.id = dto.circleID
            event.title = dto.title
            event.description = dto.description
            event.startTime = dto.startTime
            event.endTime = dto.endTime
        }
        let _ = try await helper.getCircle(req: req)
        let calendarEvent = try await helper.getCalendarEvent(req: req)
        
        let dto = try req.content.decode(CalendarEventDTO.self)
        let sanitizedDTO = try validateAndSanitize(dto)
        
        transferFields(sanitizedDTO, event: calendarEvent)
        
        try await calendarEvent.update(on: req.db)
        
        return CalendarEventDTO(from: calendarEvent)
    }
    
    func removeEvent(req: Request) async throws -> Response {
        let _ = try await helper.getCircle(req: req)
        let calendarEvent = try await helper.getCalendarEvent(req: req)
        try await calendarEvent.delete(on: req.db)
        return Response(status: .ok, body: .init(stringLiteral: "Event was removed from the database"))
    }
    
    func eventExists(_ event: CalendarEvent, on db: any Database) async throws -> Bool {
        return try await CalendarEvent.find(event.id, on: db) != nil
    }
    
    func validateAndSanitize(_ eventDTO: CalendarEventDTO) throws -> CalendarEventDTO {
        try InputValidator.validateEvent(eventDTO)
        let sanitizedDTO = InputSanitizer.sanitizeEvent(eventDTO)
        return sanitizedDTO
    }
    
}
