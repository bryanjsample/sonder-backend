//
//  CalendarEventDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor

struct CalendarEventDTO: Content {
    var id: UUID?
    var hostID: UUID
    var circleID: UUID
    var title: String
    var description: String
    var startTime: Date
    var endTime: Date
    var createdAt: Date?
    
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
}

extension CalendarEventDTO {
    
    init(from event: CalendarEvent) {
        self.id = event.id ?? nil
        self.hostID = event.$host.id
        self.circleID = event.$circle.id
        self.title = event.title
        self.description = event.description
        self.startTime = event.startTime
        self.endTime = event.endTime
        self.createdAt = event.createdAt
    }
    
}
