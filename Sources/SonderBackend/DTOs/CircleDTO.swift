//
//  CircleDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Vapor

struct CircleDTO: Content {
    
    var id: UUID?
    var name: String
    var description: String
    var pictureUrl: String?
    
    func toModel() -> Circle {
        let model = Circle()
        model.id = self.id ?? nil
        model.name = self.name
        model.description = self.description
        model.pictureUrl = self.pictureUrl ?? nil
        return model
    }
    
}

extension CircleDTO {
    init() {
        self.id = nil
        self.name = ""
        self.description = ""
        self.pictureUrl = nil
    }
    
    init(from circle: Circle) {
        self.id = circle.id ?? nil
        self.name = circle.name
        self.description = circle.description
        self.pictureUrl = circle.pictureUrl ?? nil
    }
}
