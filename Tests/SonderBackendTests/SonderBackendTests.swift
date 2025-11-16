@testable import SonderBackend
import VaporTesting
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct SonderBackendTests {
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
    
    @Test("Test /users POST")
    func createUser() async throws {
        let newUser = UserDTO(email: "bryanjsample@yahoo.com", firstName: "Bryan", lastName: "Sample", username: "bsizzle", pictureUrl: nil)
        try await withApp { app in
            try await app.testing().test(.POST, "users", beforeRequest: { req in
                print(req.content)
                try req.content.encode(newUser)
                print(req.content)
            }, afterResponse: {res in
                switch res.status {
                case .created:
                    print("User successfully created.")
                case .conflict:
                    print("User already exists in database.")
                default:
                    print("Unexpected Response")
                }
            })
        }
    }
    
    @Test("Test /users/:userID GET")
    func getUser() async throws {
        let newUser = User(email: "richieflores@gmail.com", firstName: "Richie", lastName: "Flores", username: "cstitans22", pictureUrl: nil)
        try await withApp { app in
            try await newUser.save(on: app.db)
            let newUserID = newUser.id?.uuidString ?? "id_missing"
            try await app.testing().test(.GET, "users/\(newUserID)", afterResponse: {res in
                print(res.content)
                #expect(res.status == .ok)
            })
        }
    }
}

