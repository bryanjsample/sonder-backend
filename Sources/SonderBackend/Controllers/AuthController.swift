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
            let userInfo = try await Google.getUser(on: req)
            let query = try URLEncodedFormEncoder().encode(userInfo)
            return req.redirect(to: "/auth/google/success?\(query)")
        }

        let success = routes.grouped("auth", "google", "success")
        success.get(use: processGoogleUser)

    }

    func processGoogleUser(req: Request) async throws -> Response {
        func retrieveUserToken(_ user: User) async throws -> Response {

            /* NEED TO:
             ADD TOKEN LIFETIMES
             QUERY FOR MOST RECENT TOKEN?
             AUTO DROP EXPIRED TOKENS FROM DB?
             */

            if let token = try await user.$token.query(on: req.db).first() {
                let dto = UserTokenDTO(from: token)
                return try helper.sendResponseObject(dto: dto)
            } else {
                throw Abort(
                    .unauthorized,
                    reason: "User doesnt have a registered token"
                )
            }
        }
        func onboardNewUser() async throws -> Response {
            let newUser = try User(
                email: userInfo.email,
                firstName: userInfo.givenName,
                lastName: userInfo.familyName,
                pictureUrl: userInfo.picture,

            )
            try await newUser.save(on: req.db)
            let token = try newUser.generateToken()
            try await token.save(on: req.db)
            let dto = UserTokenDTO(from: token)
            return try helper.sendResponseObject(dto: dto)
        }
        let userInfo = try req.query.decode(GoogleUserInfo.self)
        if let existingUser = try await User.query(on: req.db)
            .filter(\.$email == userInfo.email)
            .first() {
            return try await retrieveUserToken(existingUser)
        } else {
            return try await onboardNewUser()
        }
    }
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
