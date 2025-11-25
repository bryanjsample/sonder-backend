//
//  Token.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/24/25.
//

import Vapor
import Fluent
import ImperialCore

final class Token: Model, @unchecked Sendable,  {
    static let schema = "tokens"
}
