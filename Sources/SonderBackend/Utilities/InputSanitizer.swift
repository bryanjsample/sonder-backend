//
//  InputSanitizer.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/16/25.
//

enum InputSanitizer {
    static func sanitizeUser(_ user: UserDTO) -> UserDTO {
        var sanitizedDTO = UserDTO()
        sanitizedDTO.id = user.id ?? nil
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
    
    static func sanitizeCircle(_ circle: CircleDTO) -> CircleDTO {
        var sanitizedDTO = CircleDTO()
        sanitizedDTO.id = circle.id ?? nil
        sanitizedDTO.name = sanitizeCircleName(circle.name)
        sanitizedDTO.description = sanitizeTextBlock(circle.description)
        if let pictureUrl = circle.pictureUrl {
            sanitizedDTO.pictureUrl = sanitizePictureUrl(pictureUrl)
        }
        return sanitizedDTO
    }
    
    static func sanitizePost(_ post: PostDTO) -> PostDTO {
        let id = post.id ?? nil
        let circle = sanitizeCircle(CircleDTO(from: post.circle)).toModel()
        let author = sanitizeUser(UserDTO(from: post.author)).toModel()
        let content = sanitizeTextBlock(post.content)
        let createdAt = post.createdAt ?? nil
        return PostDTO(id: id, circle: circle, author: author, content: content, createdAt: createdAt)
    }
    
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
    
    static func sanitizeCircleName(_ name: String) -> String {
        name
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    static func sanitizeTextBlock(_ textBlock: String) -> String {
        textBlock
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    

    



    

}
