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
        
        let auth = routes.grouped("auth")
        
        guard let googleCallbackURL = Environment.get("GOOGLE_CALLBACK_URL") else {
            throw Abort(.badRequest, reason: "Google callback url not found")
        }
        
        try auth.oAuth(
            from:  Google.self,
            authenticate: "google",
            authenticateCallback: { req in
                let userInfo = try await Google.getUser(on: req)
                req.logger.info("userInfo = \(userInfo)")
                let foundUser = try await User.query(on: req.db)
                    .filter(\.$email == userInfo.email)
                    .first()
                guard let existingUser = foundUser else {
                    let user = try User(email: userInfo.email, firstName: userInfo.name, lastName: userInfo.name)
                    req.logger.info("user = \(user)")
                    try await user.save(on: req.db)
                    req.session.authenticate(user)
                    return
                }
                req.logger.info("existingUser = \(existingUser)")
                req.session.authenticate(existingUser)
            },
            callback: googleCallbackURL,
            scope: [
                "https://www.googleapis.com/auth/userinfo.email",
                "https://www.googleapis.com/auth/userinfo.profile"
            ]) { req, _ in
                return req.redirect(to: "/")
        }
        
        let success = auth.grouped("google", "success")
        success.get(use: googleSuccess)
        
    }
    
    func googleSuccess(req: Request) -> String {
        "It worked"
    }
}

struct GoogleUserInfo: Content {
    let email: String
    let name: String
}

extension Google {
    static func getUser(on req: Request) async throws -> GoogleUserInfo {
        var headers = HTTPHeaders()
        headers.bearerAuthorization = try BearerAuthorization(token: req.accessToken)
        req.logger.info("headers = \(headers)")
        let googleAPIURL: URI = "https://www.googleapis.com/oauth2/v1/userinfo?alt=json"
        let response =  try await req.client.get(googleAPIURL, headers: headers)
        req.logger.info("responseContent = \(response.content)")
        guard response.status == .ok else {
            if response.status == .unauthorized {
                throw Abort.redirect(to: "auth/google")
            } else {
                throw Abort(.internalServerError, reason: "Authentication failed")
            }
        }
        return try response.content.decode(GoogleUserInfo.self)
    }
}
