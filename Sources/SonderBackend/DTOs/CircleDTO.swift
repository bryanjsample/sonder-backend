//
//  CircleDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/14/25.
//

import Fluent
import Vapor

struct CircleDTO: Content {
    
    var id: UUID?
    var name: String
    var description: String
    var pictureUrl: String?
    
    /*
     init() {
     validate user input
     if no picture then set default
     }
     */
    
    func toModel() -> Circle {
        let model = Circle()
        model.id = self.id
        model.name = self.name
        model.description = self.description
        if let pictureUrl = self.pictureUrl {
            model.pictureUrl = pictureUrl
        }
        return model
    }
}
