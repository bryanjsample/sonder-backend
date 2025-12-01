//
//  CalendarEventsController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/13/25.
//

import Fluent
import SonderDTOs
import Vapor

struct CalendarEventsController: RouteCollection {

    // VALIDATE USER CIRCLE RELATION

    let helper = ControllerHelper()

    func boot(routes: any RoutesBuilder) throws {
        let eventsProtected = routes.grouped("circles", ":circleID", "events")
            .grouped(UserToken.authenticator())

        eventsProtected.get(use: retrieveCircleEvents)
        eventsProtected.post(use: createEvent)

        eventsProtected.group(":eventID") { event in
            event.get(use: retrieveEvent)
            event.patch(use: editEvent)
            event.delete(use: removeEvent)
        }

    }

    func retrieveCircleEvents(req: Request) async throws -> Response {
        // authenticate user on request
        let _ = try req.auth.require(User.self)

        let circle = try await helper.getCircle(req: req)

        let eventDTOs = try await circle.$events.query(on: req.db)
            .all()
            .map { CalendarEventDTO(from: $0) }
        return try helper.sendResponseObject(dto: eventDTOs)
    }

    func retrieveEvent(req: Request) async throws -> Response {
        // authenticate user on request
        let _ = try req.auth.require(User.self)

        let _ = try await helper.getCircle(req: req)
        let calendarEvent = try await helper.getCalendarEvent(req: req)

        let dto = CalendarEventDTO(from: calendarEvent)
        return try helper.sendResponseObject(dto: dto)
    }

    func createEvent(req: Request) async throws -> Response {
        // authenticate user on request
        let user = try req.auth.require(User.self)

        let circle = try await helper.getCircle(req: req)

        var eventDTO = try req.content.decode(CalendarEventDTO.self)
        eventDTO.hostID = user.id!
        eventDTO.circleID = circle.id!
        let sanitizedDTO = try eventDTO.validateAndSanitize()
        let calendarEvent = sanitizedDTO.toModel()
        if try await calendarEvent.exists(on: req.db) {
            throw Abort(.conflict, reason: "Event already exists")
        } else {
            try await calendarEvent.save(on: req.db)
            let dto = CalendarEventDTO(from: calendarEvent)
            return try helper.sendResponseObject(dto: dto)
        }
    }

    func editEvent(req: Request) async throws -> Response {
        func transferFields(_ dto: CalendarEventDTO, event: CalendarEvent) {
            event.$host.id = dto.hostID
            event.$circle.id = dto.circleID
            event.title = dto.title
            event.description = dto.description
            event.startTime = dto.startTime
            event.endTime = dto.endTime
        }
        // authenticate user on request
        let _ = try req.auth.require(User.self)

        let _ = try await helper.getCircle(req: req)
        let calendarEvent = try await helper.getCalendarEvent(req: req)
        let dto = try req.content.decode(CalendarEventDTO.self)
        let sanitizedDTO = try dto.validateAndSanitize()
        transferFields(sanitizedDTO, event: calendarEvent)
        try await calendarEvent.update(on: req.db)
        let resDTO = CalendarEventDTO(from: calendarEvent)
        return try helper.sendResponseObject(dto: resDTO)
    }

    func removeEvent(req: Request) async throws -> Response {
        // authenticate user on request
        let _ = try req.auth.require(User.self)

        let _ = try await helper.getCircle(req: req)
        let calendarEvent = try await helper.getCalendarEvent(req: req)
        try await calendarEvent.delete(on: req.db)
        return Response(
            status: .ok,
            body: .init(stringLiteral: "Event was removed from the database")
        )
    }
}

extension CalendarEventDTO {

    func toModel() -> CalendarEvent {
        let model = CalendarEvent()
        model.id = self.id
        model.$host.id = self.hostID
        model.$circle.id = self.circleID
        model.title = self.title
        model.description = self.description
        model.startTime = self.startTime
        model.endTime = self.endTime
        model.createdAt = self.createdAt
        return model
    }

    init(from event: CalendarEvent) {
        self.init(
            id: event.id,
            hostID: event.$host.id,
            circleID: event.$circle.id,
            title: event.title,
            description: event.description,
            startTime: event.startTime,
            endTime: event.endTime,
            createdAt: event.createdAt
        )
    }

}
