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
            scope: ["profile", "email"]) { req, token in
                req.logger.info("token = \(token)")
                let userInfo = try await Google.getUser(on: req)
                req.logger.info("userInfo = \(userInfo)")
                if let existingUser = try await User.query(on: req.db)
                    .filter(\.$email == userInfo.email)
                    .first() {
                    req.logger.info("existingUser = \(existingUser)")
                    req.auth.login(existingUser)
                } else {
                    let user = try User(
                        email: userInfo.email,
                        firstName: userInfo.name,
                        lastName: userInfo.name
                    )
                    req.logger.info("user = \(user)")
                    try await user.save(on: req.db)
                    req.auth.login(user)
                }

                return req.redirect(to: "/auth/google/success")
        }
        
        let success = routes.grouped("auth", "google", "success")
        success.get(use: googleSuccess)
        
    }
    
    func googleSuccess(req: Request) async throws -> Google.GoogleUserInfo {
        guard let user = req.auth.get(User.self) else {
            throw Abort(.unauthorized)
        }
        let query = try req.query.decode(OAuthCallbackQuery.self)
        
        req.logger.info("code = \(query.code)")
        if let scope = query.scope {
            req.logger.info("scope = \(scope)")
        }
        if let authUser = query.authuser {
            req.logger.info("authUser = \(authUser)")
        }
        if let prompt = query.prompt {
            req.logger.info("prompt = \(prompt)")
        }
        return try await Google.getUser(on: req)
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
