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
        
        guard let googleCallbackURL = ProcessInfo.processInfo.environment["GOOGLE_CALLBACK_URL"] else {
            throw Abort(.badRequest, reason: "Google callback url not found")
        }
        
        try routes.oAuth(
            from:  Google.self,
            authenticate: "auth/google",
            callback: googleCallbackURL,
            scope: ["profile", "email"]) { req, accToken in
                let userInfo = try await Google.getUser(on: req)
                let query = try URLEncodedFormEncoder().encode(userInfo)
                return req.redirect(to: "/auth/google/success?\(query)")
        }
        
        let success = routes.grouped("auth", "google", "success")
        success.get(use: processGoogleUser)
        
    }
    
    func processGoogleUser(req: Request) async throws -> UserTokenDTO {
        func retrieveUserToken(_ user: User) async throws -> UserTokenDTO {
            
            /* NEED TO:
             ADD TOKEN LIFETIMES
             QUERY FOR MOST RECENT TOKEN?
             AUTO DROP EXPIRED TOKENS FROM DB?
             */
            
            if let token = try await user.$token.query(on: req.db).first() {
                return UserTokenDTO(from: token)
            } else {
                throw Abort(.unauthorized, reason: "User doesnt have a registered token")
            }
        }
        func onboardNewUser() async throws -> UserTokenDTO {
            let newUser = try User(
                email: userInfo.email,
                firstName: userInfo.given_name,
                lastName: userInfo.family_name,
                pictureUrl: userInfo.picture,
                
            )
            try await newUser.save(on: req.db)
            let token = try newUser.generateToken()
            try await token.save(on: req.db)
            return UserTokenDTO(from: token)
        }
        let userInfo = try req.query.decode(Google.GoogleUserInfo.self)
        if let existingUser = try await User.query(on: req.db)
            .filter(\.$email == userInfo.email)
            .first() {
            return try await retrieveUserToken(existingUser)
        } else {
            return try await onboardNewUser()
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
        let email_verified: Bool
        let given_name: String
        let family_name: String
        let picture: String?
    }
    
    static func getUser(on req: Request) async throws -> Google.GoogleUserInfo {
        var headers = HTTPHeaders()
        headers.bearerAuthorization = try BearerAuthorization(token: req.accessToken)
        let googleAPIURL: URI = "https://openidconnect.googleapis.com/v1/userinfo"
        let response =  try await req.client.get(googleAPIURL, headers: headers)
        guard response.status == .ok else {
            if response.status == .unauthorized {
                throw Abort.redirect(to: "/auth/google")
            } else {
                throw Abort(.internalServerError, reason: "Authentication failed in an unexpected way")
            }
        }

        let googInfo =  try response.content.decode(GoogleUserInfo.self)
        
        if googInfo.email_verified {
            req.logger.info("email is verified")
            return googInfo
        } else {
            req.logger.info("email is not verified")
            throw Abort(.unauthorized, reason: "Google email is not verified. Please verify email and attempt onboarding again.")
        }
    }
}
