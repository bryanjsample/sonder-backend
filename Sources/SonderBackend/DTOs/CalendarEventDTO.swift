//
//  CalendarEventDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Vapor

struct CalendarEventDTO: Content {
    var id: UUID?
    var host: User
    var circle: Circle
    var title: String
    var description: String
    var startTime: Date
    var endTime: Date
    
    func toModel() -> CalendarEvent {
        let model = CalendarEvent()
        model.id = self.id
        model.host = self.host
        model.circle = self.circle
        model.description = self.description
        model.startTime = self.startTime
        model.endTime = self.endTime
        return model
    }
}
