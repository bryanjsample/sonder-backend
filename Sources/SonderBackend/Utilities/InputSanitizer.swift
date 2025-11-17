//
//  InputSanitizer.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/16/25.
//

enum InputSanitizer {
    static func sanitizeName(_ name: String) -> String {
        let trimmedName = name.trimmingCharacters(in: .newlines)
        let components = trimmedName.split(separator: " ")
        let sanitizedName = components.map { part in
            part.prefix(1).uppercased() + part.dropFirst().lowercased()
        }.joined(separator: " ")
            .precomposedStringWithCanonicalMapping
        return sanitizedName
    }
        
    static func sanitizeEmail(_ email: String) -> String {
        email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
    
    static func sanitizeUsername(_ username: String) -> String {
        username
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func sanitizePictureUrl(_ pictureUrl: String) -> String {
        pictureUrl
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func sanitizeUser(_ user: UserDTO) -> UserDTO {
        var sanitizedDTO = UserDTO()
        sanitizedDTO.email = sanitizeEmail(user.email)
        sanitizedDTO.firstName = sanitizeName(user.firstName)
        sanitizedDTO.lastName = sanitizeName(user.lastName)
        if let username = user.username {
            sanitizedDTO.username = sanitizeUsername(username)
        }
        if let pictureUrl = user.pictureUrl {
            sanitizedDTO.pictureUrl = sanitizePictureUrl(pictureUrl)
        }
        return sanitizedDTO
    }
    



    

}
