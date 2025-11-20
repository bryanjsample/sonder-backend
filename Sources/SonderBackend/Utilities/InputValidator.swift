//
//  InputValidator.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/16/25.
//

import Foundation

enum InputValidator {
    
    static func validateUser(_ user: UserDTO) throws {
        try validateString(data: user.email, inputField: InputField.email)
        try validateString(data: user.firstName, inputField: InputField.name)
        try validateString(data: user.lastName, inputField: InputField.name)
        if let username = user.username {
            try validateString(data: username, inputField: InputField.username)
        }
        if let pictureUrl = user.pictureUrl {
            try validateString(data: pictureUrl, inputField: InputField.pictureUrl)
        }
    }
    
    static func validateCircle(_ circle: CircleDTO) throws {
        try validateString(data: circle.name, inputField: InputField.title)
        try validateString(data: circle.description, inputField: InputField.description)
        if let pictureUrl = circle.pictureUrl {
            try validateString(data: pictureUrl, inputField: InputField.pictureUrl)
        }
    }
    
    static func validatePost(_ post: PostDTO) throws {
        try validateCircle(CircleDTO(from: post.circle))
        try validateUser(UserDTO(from: post.author))
        try validateString(data: post.content, inputField: InputField.textBlock)
    }
    
    static func validateEvent(_ event: CalendarEventDTO) throws {
        try validateUser(UserDTO(from: event.host))
        try validateCircle(CircleDTO(from: event.circle))
        try validateString(data: event.title, inputField: InputField.title)
        try validateString(data: event.description, inputField: InputField.description)
        guard event.startTime < event.endTime else {
            throw ValidationError("Event start time must be before it's end time")
        }
        guard Date() <= event.startTime else {
            throw ValidationError("Event cannot start in the past")
        }
    }
    
    static func validateString(data: String, inputField: InputField) throws {
        func usesOauthHost() throws -> Bool {
            let oauthHosts = ["googleusercontent.com", "ggpht.com", "lh3.googleusercontent.com"]
            guard let components = URLComponents(string: trimmed) else {
                throw ValidationError("URL does not have valid components")
            }
            return oauthHosts.contains(components.host ?? "")
        }
        
        func validateRegex(newPattern: String? = nil) throws {
            let pattern = newPattern ?? inputField.regexPattern
            
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            
            let range = NSRange(location: 0, length: trimmed.utf16.count)
            guard regex.firstMatch(in: trimmed, range: range) != nil else {
                throw ValidationError("Invalid \(inputField.description) type")
            }
        }
        
        let trimmed = data.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            throw ValidationError("\(inputField.description) cannot be empty")
        }
        
        switch inputField.description {
        case "pictureUrl":
            if try usesOauthHost() {
                let oauthPattern = #"^https?:\/\/[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)*+(?:\/[^\s?#<>%]*)?(?:\?[^\s#<>%]*)?(?:#[^\s<>%]*)?$"#
                try validateRegex(newPattern: oauthPattern)
            } else {
                try validateRegex()
            }
        default:
            try validateRegex()
        }
    }

}

struct ValidationError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
    init(_ message: String) { self.message = message }
}

