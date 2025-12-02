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
        
        auth.group("refresh") { refresh in
            refresh.get(use: processRefreshToken)
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
        
        let user = refreshToken.owner
        
        if refreshToken.isValid {
            req.logger.info("Refresh token is valid.")
            try await user.revokeAllAccessTokens(req: req)
            
            let accessToken = try await user.generateAccessToken(req: req)
            try await accessToken.save(on: req.db)
            
            let accessDTO = AccessTokenDTO(from: accessToken)
            let refreshDTO = RefreshTokenDTO(from: refreshToken)
            let resDTO = TokenResponseDTO(accessToken: accessDTO, refreshToken: refreshDTO)
            return try helper.sendResponseObject(dto: resDTO)
        } else {
            req.logger.info("Refresh token is not valid.")
            try await user.revokeAllTokens(req: req)
            return req.redirect(to: "/auth/google")
        }
    }

    func processGoogleUser(req: Request) async throws -> Response {
        let userInfo = try req.query.decode(GoogleUserInfo.self)
        if let existingUser = try await User.query(on: req.db)
            .filter(\.$email == userInfo.email)
            .first() {
            let accessToken = try await existingUser.generateAccessToken(req: req)
            try await accessToken.save(on: req.db)
            let accessDTO = AccessTokenDTO(from: accessToken)
            
            let refreshToken = try await existingUser.generateRefreshToken(req: req)
            try await refreshToken.save(on: req.db)
            let refreshDTO = RefreshTokenDTO(from: refreshToken)
            
            let resDTO = TokenResponseDTO(accessToken: accessDTO, refreshToken: refreshDTO)
            return try helper.sendResponseObject(dto: resDTO)
        } else {
            return try await onboardNewUser(req: req, userInfo: userInfo)
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
        
        let accessToken = try await newUser.generateAccessToken(req: req)
        try await accessToken.save(on: req.db)
        let accessDTO = AccessTokenDTO(from: accessToken)
        
        let refreshToken = try await newUser.generateRefreshToken(req: req)
        try await refreshToken.save(on: req.db)
        let refreshDTO = RefreshTokenDTO(from: refreshToken)
        
        let resDTO = TokenResponseDTO(accessToken: accessDTO, refreshToken: refreshDTO)
        return try helper.sendResponseObject(dto: resDTO)
    }
    
}

extension AccessTokenDTO {
    init(from access: AccessToken) {
        self.init(
            token: access.token,
            ownerID: access.$owner.id,
            expiresAt: access.expiresAt,
            revoked: access.revoked
        )
    }
    
    func toModel() -> AccessToken {
        let model = AccessToken()
        model.token = self.token
        model.$owner.id = self.ownerID
        model.expiresAt = self.expiresAt
        model.revoked = self.revoked
        return model
    }
}

extension RefreshTokenDTO {
    init(from refresh: RefreshToken) {
        self.init(
            token: refresh.token,
            ownerID: refresh.$owner.id,
            expiresAt: refresh.expiresAt,
            revoked: refresh.revoked
        )
    }
    
    func toModel() -> RefreshToken {
        let model = RefreshToken()
        model.token = self.token
        model.$owner.id = self.ownerID
        model.expiresAt = self.expiresAt
        model.revoked = self.revoked
        return model
    }
}

struct IncomingRefreshToken: Content {
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
