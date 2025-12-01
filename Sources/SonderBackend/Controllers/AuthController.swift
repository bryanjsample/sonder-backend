//
//  AuthController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/23/25.
//

import Fluent
import ImperialGoogle
import SonderDTOs
import Vapor

struct AuthController: RouteCollection {

    let helper = ControllerHelper()

    func boot(routes: any RoutesBuilder) throws {

        guard
            let googleCallbackURL = ProcessInfo.processInfo.environment[
                "GOOGLE_CALLBACK_URL"
            ]
        else {
            throw Abort(.badRequest, reason: "Google callback url not found")
        }

        try routes.oAuth(
            from: Google.self,
            authenticate: "auth/google",
            callback: googleCallbackURL,
            scope: ["profile", "email"]
        ) { req, _ in
            req.logger.info("made it to callback code")
            let userInfo = try await Google.getUser(on: req)
            let query = try URLEncodedFormEncoder().encode(userInfo)
            return req.redirect(to: "/auth/google/success?\(query)")
        }
        
        let auth = routes.grouped("auth")
        
        auth.group("refresh") { login in
            login.get(use: processRefreshToken)
        }

        auth.group("google", "success") { googleSuccess in
            googleSuccess.get(use: processGoogleUser)
        }

    }
    
    func processRefreshToken(req: Request) async throws -> Response {
        let incomingToken = try req.content.decode(IncomingRefreshToken.self)
        guard let refreshToken = try await RefreshToken.query(on: req.db)
            .filter(\.$token == incomingToken.token)
            .first() else {
            req.logger.info("Refresh token does not exist.")
            return req.redirect(to: "/auth/google")
        }
        if refreshToken.isValid {
            let user = refreshToken.owner
            // revoke all other tokens associate with user
            let accessToken = try user.generateAccessToken()
            try await accessToken.save(on: req.db)
            
            let accessDTO = AccessTokenDTO(from: accessToken)
            let refreshDTO = RefreshTokenDTO(from: refreshToken)
            let resDTO = TokenResponseDTO(accessToken: accessDTO, refreshToken: refreshDTO)
            return try helper.sendResponseObject(dto: resDTO)
        } else {
            req.logger.info("Refresh token is not valid.")
            return req.redirect(to: "/auth/google")
        }
    }

    func processGoogleUser(req: Request) async throws -> Response {
        let userInfo = try req.query.decode(GoogleUserInfo.self)
        if let existingUser = try await User.query(on: req.db)
            .filter(\.$email == userInfo.email)
            .first() {
            let accessToken = try await retrieveAccessToken(existingUser, req: req) ?? existingUser.generateAccessToken()
            let refreshToken = try await retrieveRefreshToken(existingUser, req: req) ?? existingUser.generateRefreshToken()
            let accessDTO = AccessTokenDTO(from: accessToken)
            let refreshDTO = RefreshTokenDTO(from: refreshToken)
            let resDTO = TokenResponseDTO(accessToken: accessDTO, refreshToken: refreshDTO)
            return try helper.sendResponseObject(dto: resDTO)
        } else {
            return try await onboardNewUser(req: req, userInfo: userInfo)
        }
    }
    
    func retrieveAccessToken(_ user: User, req: Request) async throws -> AccessToken? {
        req.logger.info("inside retrieveAccessToken")
        guard let accessToken = try await user.$accessTokens.query(on: req.db)
            .filter(\.$revoked == false)
            .first() else {
            req.logger.info("User doesn't have a registered access token")
            return nil
        }
        if accessToken.isValid {
            return accessToken
        } else {
            accessToken.revoked = true
            try await accessToken.update(on: req.db)
            req.logger.info("access token is invalid, need to consult refresh token")
            return nil
        }
    }
    
    func retrieveRefreshToken(_ user: User, req: Request) async throws -> RefreshToken? {
        req.logger.info("inside retrieveRefreshToken")
        guard let refreshToken = try await user.$refreshTokens.query(on: req.db)
            .filter(\.$revoked == false)
            .first() else {
            req.logger.info("User doesn't have a registered refresh token.")
            return nil
        }
        if refreshToken.isValid {
            return refreshToken
        } else {
            refreshToken.revoked = true
            try await refreshToken.update(on: req.db)
            req.logger.info("refresh token is invalid, need to log back in")
            return nil
        }
    }
    
    func onboardNewUser(req: Request, userInfo: GoogleUserInfo) async throws -> Response {
        let newUser = try User(
            email: userInfo.email,
            firstName: userInfo.givenName,
            lastName: userInfo.familyName,
            pictureUrl: userInfo.picture,

        )
        try await newUser.save(on: req.db)
        
        let accessToken = try newUser.generateAccessToken()
        try await accessToken.save(on: req.db)
        let accessDTO = AccessTokenDTO(from: accessToken)
        
        let refreshToken = try newUser.generateRefreshToken()
        try await refreshToken.save(on: req.db)
        let refreshDTO = RefreshTokenDTO(from: refreshToken)
        
        let resDTO = TokenResponseDTO(accessToken: accessDTO, refreshToken: refreshDTO)
        return try helper.sendResponseObject(dto: resDTO)
    }
    
}

struct IncomingRefreshToken: Codable {
    let token: String
}

struct GoogleUserInfo: Content {
    let email: String
    let emailVerified: Bool
    let givenName: String
    let familyName: String
    let picture: String?

    enum CodingKeys: String, CodingKey {
        case email
        case emailVerified = "email_verified"
        case givenName = "given_name"
        case familyName = "family_name"
        case picture
    }
}

extension Google {
    static func getUser(on req: Request) async throws -> GoogleUserInfo {
        var headers = HTTPHeaders()
        headers.bearerAuthorization = try BearerAuthorization(
            token: req.accessToken
        )
        let googleAPIURL: URI =
            "https://openidconnect.googleapis.com/v1/userinfo"
        let response = try await req.client.get(googleAPIURL, headers: headers)
        guard response.status == .ok else {
            if response.status == .unauthorized {
                throw Abort.redirect(to: "/auth/google")
            } else {
                throw Abort(
                    .internalServerError,
                    reason: "Authentication failed in an unexpected way"
                )
            }
        }

        let googInfo = try response.content.decode(GoogleUserInfo.self)

        if googInfo.emailVerified {
            req.logger.info("email is verified")
            return googInfo
        } else {
            req.logger.info("email is not verified")
            throw Abort(
                .unauthorized,
                reason:
                    "Google email is not verified. Please verify email and attempt onboarding again."
            )
        }
    }
}
