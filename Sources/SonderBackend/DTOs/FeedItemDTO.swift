//
//  FeedItemDTO.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/20/25.
//

import Vapor

enum FeedItemDTO: Codable {
    case post(PostDTO)
    case event(CalendarEventDTO)

    enum CodingKeys: String, CodingKey {
        case type
        case post
        case event
    }

    enum ItemType: String, Codable {
        case post
        case event
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ItemType.self, forKey: .type)
        switch type {
        case .post:
            let value = try container.decode(PostDTO.self, forKey: .post)
            self = .post(value)
        case .event:
            let value = try container.decode(CalendarEventDTO.self, forKey: .event)
            self = .event(value)
        }
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .post(let dto):
            try container.encode(ItemType.post, forKey: .type)
            try container.encode(dto, forKey: .post)
        case .event(let dto):
            try container.encode(ItemType.event, forKey: .type)
            try container.encode(dto, forKey: .event)
        }
    }

    var createdAt: Date? {
        switch self {
        case .post(let p): return p.createdAt
        case .event(let e): return e.createdAt
        }
    }
}
