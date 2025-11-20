//
//  FeedResponseDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/20/25.
//

import Vapor

struct FeedResponseDTO: Content {
    let items: [FeedItemDTO]
//    let nextCursor: String?
}
