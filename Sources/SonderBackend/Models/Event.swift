//
//  Event.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import struct Foundation.UUID

final class Event: Model, @unchecked Sendable {
    static let schema = "events"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String
    
//    @Field(key: "start_time")
//    var startTime: DateTime
//    
//    @Field(key: "end_time")
//    var endTime: DateTime
//    
//    @Field(key: "location")
//    var location: Location
//    
//    @Field(key: "last_modified")
//    var lastModified: DateTime
//
//    @Children(key: "attendees")        this is a one->many relationship between event and an array of users
//    var attendees: [User.IDValue]
    
    @Parent(key: "hostID")
    var host: User
    
    @Parent(key: "circleID")
    var circle: Circle
    
    init() { }
    
    init(
        id: UUID? = nil,
        title: String,
        description: String,
        hostID: User.IDValue,
        circleID: Circle.IDValue
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.$host.id = hostID
        self.$circle.id = circleID
    }
}
