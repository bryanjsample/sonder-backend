//
//  UserTests.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/17/25.
//

@testable import SonderBackend
import VaporTesting
import Testing
import Fluent

@Suite("User Tests", .serialized)
struct UserTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    let userDTOs = [
        UserDTO(email: "bryanjsample@yahoo.com", firstName: "Bryan", lastName: "Sample", username: "bsizzle", pictureUrl: nil),
        UserDTO(email: "richie.flores@bemidjistate.edu", firstName: "Richie", lastName: "Flores", username: "cstitans22", pictureUrl: "https://lh3.googleusercontent.com/a-/AOh14GiAbCdEf"),
        UserDTO(email: "marie.curie@example.com", firstName: "Marie", lastName: "Curie", username: nil, pictureUrl: "https://cdn.example.com/users/mcurie/avatar.png"),
        UserDTO(email: "chloe.martin@gmail.com", firstName: "Chloë", lastName: "Martin", username: "chloem", pictureUrl: nil),
        UserDTO(email: "angelo.rossi@example.org", firstName: "D’Angelo", lastName: "Rossi", username: "angelor", pictureUrl: "https://lh3.googleusercontent.com/ogw/AAELabc123"),
        UserDTO(email: "anne-marie@domain.co", firstName: "Anne-Marie", lastName: "Dupont", username: nil, pictureUrl: nil),
        UserDTO(email: "jose.alvarez@example.net", firstName: "José", lastName: "Álvarez", username: "jalvarez", pictureUrl: "https://static.domain.io/profiles/u_44/photo.jpg"),
        UserDTO(email: "luc.benoit@example.com", firstName: "Luc", lastName: "Benoît", username: nil, pictureUrl: nil),
        UserDTO(email: "francois.dupont@example.com", firstName: "François", lastName: "Dupont", username: "fdupont", pictureUrl: nil),
        UserDTO(email: "john.doe@gmail.com", firstName: "John", lastName: "Doe", username: nil, pictureUrl: nil),
        UserDTO(email: "jane.smith@hotmail.com", firstName: "Jane", lastName: "Smith", username: "jsmith", pictureUrl: nil),
        UserDTO(email: "sofia.garcia@example.io", firstName: "Sofía", lastName: "García", username: nil, pictureUrl: "https://lh3.googleusercontent.com/p/AF1QipPp9d0YxL1?sz=256"),
        UserDTO(email: "liam.brown@example.org", firstName: "Liam", lastName: "Brown", username: "liamb", pictureUrl: nil),
        UserDTO(email: "emma.wilson@example.com", firstName: "Emma", lastName: "Wilson", username: nil, pictureUrl: nil),
        UserDTO(email: "noah.johnson@example.net", firstName: "Noah", lastName: "Johnson", username: "noahj", pictureUrl: "https://sub.domain.com/path/to/img/profile.svg"),
        UserDTO(email: "olivia.thompson@example.com", firstName: "Olivia", lastName: "Thompson", username: nil, pictureUrl: nil),
        UserDTO(email: "james.anderson@example.org", firstName: "James", lastName: "Anderson", username: "janderson", pictureUrl: "https://images.site.net/pfps/user123.webp"),
        UserDTO(email: "mia.rodriguez@example.com", firstName: "Mía", lastName: "Rodríguez", username: nil, pictureUrl: nil),
        UserDTO(email: "ethan.miller@example.io", firstName: "Ethan", lastName: "Miller", username: "ethanm", pictureUrl: nil),
        UserDTO(email: "ava.martinez@example.com", firstName: "Ava", lastName: "Martínez", username: nil, pictureUrl: nil),
    ]
    
    let users = [
        User(email: "richieflores@gmail.com", firstName: "Richie", lastName: "Flores", username: "cstitans22"),
        User(email: "bryanjsample@yahoo.com", firstName: "Bryan", lastName: "Sample", username: "bsizzle", pictureUrl: nil),
        User(email: "richie.flores@bemidjistate.edu", firstName: "Richie", lastName: "Flores", username: "cstitans22", pictureUrl: "https://lh3.googleusercontent.com/a-/AOh14GiAbCdEf"),
        User(email: "marie.curie@example.com", firstName: "Marie", lastName: "Curie", username: nil, pictureUrl: "https://cdn.example.com/users/mcurie/avatar.png"),
        User(email: "chloe.martin@gmail.com", firstName: "Chloë", lastName: "Martin", username: "chloem", pictureUrl: nil),
        User(email: "angelo.rossi@example.org", firstName: "D’Angelo", lastName: "Rossi", username: "angelor", pictureUrl: "https://lh3.googleusercontent.com/ogw/AAELabc123"),
        User(email: "anne-marie@domain.co", firstName: "Anne-Marie", lastName: "Dupont", username: nil, pictureUrl: nil),
        User(email: "jose.alvarez@example.net", firstName: "José", lastName: "Álvarez", username: "jalvarez", pictureUrl: "https://static.domain.io/profiles/u_44/photo.jpg"),
        User(email: "luc.benoit@example.com", firstName: "Luc", lastName: "Benoît", username: nil, pictureUrl: nil),
        User(email: "francois.dupont@example.com", firstName: "François", lastName: "Dupont", username: "fdupont", pictureUrl: nil),
        User(email: "john.doe@gmail.com", firstName: "John", lastName: "Doe", username: nil, pictureUrl: nil),
        User(email: "jane.smith@hotmail.com", firstName: "Jane", lastName: "Smith", username: "jsmith", pictureUrl: nil),
        User(email: "sofia.garcia@example.io", firstName: "Sofía", lastName: "García", username: nil, pictureUrl: "https://lh3.googleusercontent.com/p/AF1QipPp9d0YxL1?sz=256"),
        User(email: "liam.brown@example.org", firstName: "Liam", lastName: "Brown", username: "liamb", pictureUrl: nil),
        User(email: "emma.wilson@example.com", firstName: "Emma", lastName: "Wilson", username: nil, pictureUrl: nil),
        User(email: "noah.johnson@example.net", firstName: "Noah", lastName: "Johnson", username: "noahj", pictureUrl: "https://sub.domain.com/path/to/img/profile.svg"),
        User(email: "olivia.thompson@example.com", firstName: "Olivia", lastName: "Thompson", username: nil, pictureUrl: nil),
        User(email: "james.anderson@example.org", firstName: "James", lastName: "Anderson", username: "janderson", pictureUrl: "https://images.site.net/pfps/user123.webp"),
        User(email: "mia.rodriguez@example.com", firstName: "Mía", lastName: "Rodríguez", username: nil, pictureUrl: nil),
        User(email: "ethan.miller@example.io", firstName: "Ethan", lastName: "Miller", username: "ethanm", pictureUrl: nil),
        User(email: "ava.martinez@example.com", firstName: "Ava", lastName: "Martínez", username: nil, pictureUrl: nil),
    ]
    
    @Test("Test /users POST")
    func createUser() async throws {
        try await withApp { app in
            for user in userDTOs {
                try await app.testing().test(.POST, "users", beforeRequest: { req in
                    try req.content.encode(user)
                }, afterResponse: {res in
                    #expect(res.status == .created)
                })
            }
        }
        
    }
    
    @Test("Test /users/:userID GET")
    func getUser() async throws {
        try await withApp { app in
            for user in users {
                try await user.save(on: app.db)
                let userID = user.id?.uuidString ?? "id_missing"
                try await app.testing().test(.GET, "users/\(userID)", afterResponse: {res in
                    #expect(res.status == .ok)
                })
            }
        }
    }
    
    @Test("Test /users/:userID PATCH")
    func patchUser() async throws {
        try await withApp { app in
            for user in users {
                try await user.save(on: app.db)
                let userID = user.id?.uuidString ?? "id_missing"
                var dto = UserDTO(from: user)
                dto.lastName = "PATCHED"
                try await app.testing().test(.PATCH, "users/\(userID)", beforeRequest: { req in
                    try req.content.encode(dto)
                }, afterResponse: { res in
                    #expect(res.status == .ok)
                })
            }
        }
    }
    
    @Test("Test /users/:userID DELETE")
    func deleteUser() async throws {
        try await withApp { app in
            for user in users {
                try await user.save(on: app.db)
                let userID = user.id?.uuidString ?? "id_missing"
                let dto = UserDTO(from: user)
                try await app.testing().test(.DELETE, "users/\(userID)", beforeRequest: { req in
                    try req.content.encode(dto)
                }, afterResponse: { res in
                    #expect(res.status == .ok)
                })
            }
        }
    }

}
