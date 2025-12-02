//
//  MakeTestCircle.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/20/25.
//

import Fluent
import Vapor

struct MakeTestCircle: AsyncMigration {

    func prepare(on database: any Database) async throws {
        let circle = Circle(
            name: "TEST CIRCLE",
            description: "This group is for testing only"
        )
        try await circle.save(on: database)
        try await createMembers(within: circle, on: database)
        try await createPosts(within: circle, on: database)
        try await createEvents(within: circle, on: database)
    }

    func revert(on database: any Database) async throws {
        let circle = try await Circle.query(on: database)
            .filter(\.$name == "TEST CIRCLE")
            .first()
        let members = try await User.query(on: database)
            .filter(\.$circle.$id == circle!.id)
            .all()
        let posts = try await Post.query(on: database)
            .filter(\.$circle.$id == circle!.id!)
            .all()
        let events = try await CalendarEvent.query(on: database)
            .filter(\.$circle.$id == circle!.id!)
            .all()
        try await events.delete(on: database)
        try await posts.delete(on: database)
        try await members.delete(on: database)
        try await circle?.delete(on: database)
    }

    func createMembers(within circle: Circle, on database: any Database) async throws {
        let members = [
            try User(
                circle: circle,
                email: "testemail1@gmail.com",
                firstName: "Randy",
                lastName: "Moss",
                username: "mossyoass12"
            ),
            try User(
                circle: circle,
                email: "testemail2@gmail.com",
                firstName: "DJ",
                lastName: "Moore",
                username: "worstfirst"
            ),
            try User(
                circle: circle,
                email: "testemail3@gmail.com",
                firstName: "Peyton",
                lastName: "Manning",
                username: "goatee"
            ),
            try User(
                circle: circle,
                email: "testemail4@gmail.com",
                firstName: "Lebron",
                lastName: "James",
                username: "lebryan"
            ),
            try User(
                circle: circle,
                email: "testemail5@gmail.com",
                firstName: "Odell",
                lastName: "Beckham Jr.",
                username: "odelled"
            )
        ]
        for member in members {
            try await circle.$users.create(member, on: database)
        }
    }

    func createPosts(within circle: Circle, on database: any Database) async throws {
        let posts = [
            try Post(
                circle: circle,
                author: circle.users[0],
                content: "This is a post by randy moss."
            ),
            try Post(
                circle: circle,
                author: circle.users[1],
                content: "This is a post by dj moore"
            ),
            try Post(
                circle: circle,
                author: circle.users[2],
                content: "This is a post by peyton manning"
            ),
            try Post(
                circle: circle,
                author: circle.users[3],
                content: "This is a post by lebron james"
            ),
            try Post(
                circle: circle,
                author: circle.users[4],
                content: "This is a post by obj"
            )
        ]

        for post in posts {
            try await circle.$posts.create(post, on: database)
        }
    }

    func createEvents(within circle: Circle, on database: any Database) async throws {
        let events = [
            try CalendarEvent(
                host: circle.users[0],
                circle: circle,
                title: "Lunch",
                description: "Having lunch im randy moss",
                startTime: parse("12/3/25 12:00"),
                endTime: parse("12/3/25 13:00")
            ),
            try CalendarEvent(
                host: circle.users[1],
                circle: circle,
                title: "Breakfast",
                description: "Having breakfast im dj moore",
                startTime: parse("12/5/25 8:00"),
                endTime: parse("12/5/25 9:00")
            ),
            try CalendarEvent(
                host: circle.users[2],
                circle: circle,
                title: "Theme Park",
                description:
                    "Going to the theme park because im peyton manning",
                startTime: parse("12/7/25 8:00"),
                endTime: parse("12/7/25 16:00")
            ),
            try CalendarEvent(
                host: circle.users[3],
                circle: circle,
                title: "Work",
                description: "Im lebron why do i need to work",
                startTime: parse("12/9/25 12:00"),
                endTime: parse("12/9/25 20:00")
            ),
            try CalendarEvent(
                host: circle.users[4],
                circle: circle,
                title: "Jazz Concert",
                description: "I am obj and I enjoy jazz",
                startTime: parse("12/12/25 19:00"),
                endTime: parse("12/12/25 22:00")
            )
        ]
        try await events.create(on: database)
    }

    func parse(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy H:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let date = formatter.date(from: string) else {
            fatalError("Invalid date string: \(string)")
        }
        return date
    }

}
