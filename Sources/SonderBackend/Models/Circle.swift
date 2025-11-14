//
//  Circle.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import struct Foundation.UUID

final class Circle: Model, @unchecked Sendable {
    static let schema = "circles"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
//    @Field(key: "date_created")
//    var dateCreated: Date
    
//    @Field(key: "picture")
//    var picture: Data
    
    init() { }
    
    init(
        id: UUID? = nil,
        name: String,
        description: String
    ) {
        self.id = id
        self.name = name
        self.description = description
    }
}
