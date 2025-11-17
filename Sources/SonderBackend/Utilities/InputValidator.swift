//
//  InputValidator.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/16/25.
//

import Foundation

enum InputValidator {
    
    // necessary for user inputs
    
    static func validateString(data: String, inputField: InputField) throws {
        func usesOauthHost() throws -> Bool {
            let oauthHosts = ["googleusercontent.com", "ggpht.com", "lh3.googleusercontent.com"]
            guard let components = URLComponents(string: trimmed) else {
                throw ValidationError("URL does not have valid components")
            }
            print(components.host ?? "host is missing")
            return oauthHosts.contains(components.host ?? "")
        }
        
        func validateRegex(newPattern: String? = nil) throws {
            let pattern = newPattern ?? inputField.regexPattern
            
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            
            let range = NSRange(location: 0, length: trimmed.utf16.count)
            guard regex.firstMatch(in: trimmed, range: range) != nil else {
                print("\(data) is not a valid \(inputField.description)")
                throw ValidationError("Invalid \(inputField.description) type")
            }
            print("\(data) is a valid \(inputField.description)")
        }
        
        let trimmed = data.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            print("\(data) is an empty \(inputField.description)")
            throw ValidationError("\(inputField.description) cannot be empty")
        }
        
        switch inputField.description {
        case "pictureUrl":
            if try usesOauthHost() {
                try validateRegex()
                print("\(data) uses an OAuth host for it's \(inputField.description)")
            } else {
                let newPattern = #"^https?:\/\/[A-Za-z0-9.-]+(?:\/[^\s?#<>%]+)*\.(?:jpg|jpeg|png|gif|webp|bmp|svg)(?:\?[^\s#<>%]*)?(?:#[^\s<>%]*)?$"#
                try validateRegex(newPattern: newPattern)
            }
        default:
            try validateRegex()
        }
    }
    
    static func validateID(_ id: UUID) {
        
    }
    
//    static func validateEmail(_ email: String) throws {
//        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard !trimmed.isEmpty else {
//            print("\(email) is empty")
//            throw ValidationError("Email cannot be empty")
//        }
//        
//        let pattern = #"^(?!.*\.\.)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
//        let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
//        
//        let range = NSRange(location: 0, length: trimmed.utf16.count)
//        guard regex.firstMatch(in: trimmed, range: range) != nil else {
//            print("\(email) is not valid")
//            throw ValidationError("Invalid email format.")
//        }
//        print("\(email) is valid")
//    }
//    
//    static func validateName(_ name: String) throws {
//        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
//        
//        guard !trimmed.isEmpty else {
//            print("\(name) is empty")
//            throw ValidationError("Name cannot be empty")
//        }
//        
//        let pattern
//    }
//    
//    static func validateUsername(_ username: String) -> Bool {
//        true
//    }
//    
//    static func validatePictureUrl(_ pictureUrl: String) -> Bool {
//        true
//    }
}

struct ValidationError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
    init(_ message: String) { self.message = message }
}

