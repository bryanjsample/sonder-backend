//
//  AuthController.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/23/25.
//

import Vapor
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
            callback: googleCallbackURL,
            scope: [
                "https://www.googleapis.com/auth/userinfo.email",
                "https://www.googleapis.com/auth/userinfo.profile"
            ]) { req, token in
            print(token)
            return req.redirect(to: "/")
        }
        
        auth.group("google", "success") { google in
            google.get(use: googleSuccess)
        }
        
    }
    
    func googleSuccess(req: Request) -> String {
        "It worked"
    }
}
