//
//  AuthController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/23/25.
//

import Vapor
import Fluent
import ImperialGoogle

struct AuthController: RouteCollection {
    
    let helper = ControllerHelper()
    
    func boot(routes: any RoutesBuilder) throws {
        
        guard let googleCallbackURL = Environment.get("GOOGLE_CALLBACK_URL") else {
            throw Abort(.badRequest, reason: "Google callback url not found")
        }
        
        try routes.oAuth(
            from:  Google.self,
            authenticate: "auth/google",
            callback: googleCallbackURL,
            scope: ["profile", "email"]) { req, accToken in
                req.logger.info("token = \(accToken)")
                let userInfo = try await Google.getUser(on: req)
                let query = try URLEncodedFormEncoder().encode(userInfo)
//                return userInfo
                return req.redirect(to: "/auth/google/success?\(query)")
        }
        
        let success = routes.grouped("auth", "google", "success")
        success.get(use: processGoogleUser)
        
    }
    
    func processGoogleUser(req: Request) async throws -> UserTokenDTO {
        
        let userInfo = try req.query.decode(Google.GoogleUserInfo.self)
        
        req.logger.info("userInfo = \(userInfo)")
        if let existingUser = try await User.query(on: req.db)
            .filter(\.$email == userInfo.email)
            .first() {
            req.logger.info("existingUser = \(existingUser)")
            
            if let token = try await existingUser.$token.query(on: req.db).first() {
                return UserTokenDTO(from: token)
            } else {
                throw Abort(.internalServerError, reason: "User doesnt have a registered token")
            }
        } else {
            let newUser = try User(
                email: userInfo.email,
                firstName: userInfo.name,
                lastName: userInfo.name
            )
            req.logger.info("user = \(newUser)")
            try await newUser.save(on: req.db)
            let token = try newUser.generateToken()
            try await token.save(on: req.db)
            return UserTokenDTO(from: token)
        }
    }
}

extension AuthController {
    struct OAuthCallbackQuery: Content {
        let code: String
        let state: String?
        let scope: String?
        let authuser: String?
        let prompt: String?
    }
}

extension Google {
    struct GoogleUserInfo: Content {
        let email: String
        let name: String
    }
    
    static func getUser(on req: Request) async throws -> GoogleUserInfo {
        var headers = HTTPHeaders()
        headers.bearerAuthorization = try BearerAuthorization(token: req.accessToken)
        req.logger.info("headers = \(headers)")
        let googleAPIURL: URI = "https://openidconnect.googleapis.com/v1/userinfo"
        let response =  try await req.client.get(googleAPIURL, headers: headers)
        req.logger.info("responseContent = \(response.content)")
        guard response.status == .ok else {
            if response.status == .unauthorized {
                throw Abort.redirect(to: "/auth/google")
            } else {
                throw Abort(.internalServerError, reason: "Authentication failed")
            }
        }
        let googInfo =  try response.content.decode(GoogleUserInfo.self)
        req.logger.info("googInfo = \(googInfo)")
        return googInfo
    }
}
