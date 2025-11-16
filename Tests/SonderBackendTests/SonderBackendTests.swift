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
        let newUser = UserDTO(email: "bryanjsample@yahoo.com", firstName: "Bryan", lastName: "Sample", username: "bsizzle")
        try await withApp { app in
            try await app.testing().test(.POST, "users", beforeRequest: { req in
                try req.content.encode(newUser)
            }, afterResponse: {res in
                #expect(res.status == .created)
            })
        }
    }
    
    @Test("Test email validation on array of emails in loop")
    func validateEmails() async throws {
        let validEmails: [String] = [
            "     BryanJSAMPLE@gmAiL.com",
            "\n\t\t\t\t\t\n\n    bryanjsample@gmail.com",
            "bryan.sample@gmail.com",
            "john_doe123@yahoo.com",
            "USER+alias@protonmail.com",
            "richie.flores@bemidjistate.edu",
            "test-email@domain.co",
            "a@b.io",
        ]
        
        let invalidEmails: [String] = [
            "plainaddress",
            "@missingusername.com",
            "missingatsign.com",
            "username@.com",
            "username@domain",
            "username@domain..com",
            "user name@domain.com",
            "user<script>@gmail.com",
            "user\"quote\"@gmail.com",
            "line\nbreak@domain.com",
            "user()@gmail.com",
            "user@@domain.com",
            "skibidi totilet bryan jsame",
            "SELECT * FROM vapor",
            "scd2999045.1233422123@yahoo.com/sckiii   ",
        ]
        
        let emptyEmails: [String] = [
            "       ",
            "",
"""

""",
            "                                     ",
            "\n\n\n\n\n\n\n",
            "\t\t\t\t\t\t\t\t",
            "\n\n                 \t\t                 \n\n                  \t\t",
        ]
        
        for email in validEmails {
            #expect(throws: Never.self) {
                try InputValidator.validateString(data: email, inputField: InputField.email)
            }
        }
        
        for email in invalidEmails {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(data: email, inputField: InputField.email)
            }
        }
        
        for email in emptyEmails {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(data: email, inputField: InputField.email)
            }
        }
    }
    
    @Test("Test name validation on array of names")
    func validateNames() async throws {
        let validNames = [
            "Bryan",
            "Bryan Sample",
            "Jean-Luc",
            "María García",
            "Chloë",
            "D’Angelo",
            "François Dupont",
            "José Álvarez",
            "Anne-Marie",
            "O’Connor"
        ]
        
        let invalidNames = [
            "Br2yan",
            "John_Doe",
            "Jane@Smith",
            "!!!",
            "Robert123",
            "Anne--Marie",
            ";DROP TABLE users;",
            "12345"
        ]
        
        let emptyNames = [
            "",
            " ",
            "     ",
            "\n",
            "\t",
            "\n\n\n",
            "\t\t\t",
            " \n \t ",
            "",
            "\r\n"
        ]
        
        for name in validNames {
            #expect(throws: Never.self) {
                try InputValidator.validateString(data: name, inputField: InputField.name)
            }
        }
        
        for name in invalidNames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(data: name, inputField: InputField.name)
            }
        }
        
        for name in emptyNames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(data: name, inputField: InputField.name)
            }
        }
    }
    
    @Test("Test username validation on array of usernames")
    func validateUsernames() async throws {
        let validUsernames = [
            "bryan123",
            "b_sample",
            "johnDoe",
            "richie_flores22",
            "user_1",
            "TestUser",
            "swiftDev2025",
            "hello_world",
            "alphaBeta99",
            "CS_Student",
        ]
        
        let invalidUsernames = [
            "ab",                 // too short
            "thisusernameiswaytoolongtobefunctional", // too long
            "user name",          // space
            "user-name",          // hyphen not allowed
            "user.name",          // dot not allowed
            "user@name",          // symbol not allowed
            "🔥fireboy",          // emoji
            "123456",             // numeric only (if you disallow this, optional)
            "_startsWithUnderscore", // leading underscore
            "endsWithUnderscore_",   // trailing underscore
        ]
        
        let emptyUsernames = [
            "",
            " ",
            "     ",
            "\n",
            "\t",
            "\n\n",
            "\t\t",
            " \n \t ",
            "",
            "\r\n",
        ]
        
        for username in validUsernames {
            #expect(throws: Never.self) {
                try InputValidator.validateString(data: username, inputField: InputField.username)
            }
        }
        
        for username in invalidUsernames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(data: username, inputField: InputField.username)
            }
        }
        
        for username in emptyUsernames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(data: username, inputField: InputField.username)
            }
        }

    }
    
    @Test("Test pictureUrl validation on array of pictureUrls")
    func validatePictureUrls() async throws {
        let validPictureUrls = [
            "https://lh3.googleusercontent.com/a-/AOh14GiAbCdEf",
            "https://lh3.googleusercontent.com/ogw/AAEL12345?w=200-h=200",
            "https://example.com/images/profile.jpg",
            "http://cdn.myapp.io/user/123/avatar.png",
            "https://static.server.net/u/photo.webp",
            "https://profiles.google.com/user/photo",
            "https://images.domain.org/users/abc123/profile.jpeg?size=400",
            "https://mycdn.cloudhost.com/avatars/avatar123",
            "https://example.io/pfp.svg#v2",
            "https://sub.domain.com/path/to/resource/photo.gif",
        ]
        
        let invalidPictureUrls = [
            "ftp://example.com/image.jpg",                     // unsupported scheme
            "javascript:alert('xss')",                         // dangerous scheme
            "data:image/png;base64,iVBORw0KGgoAAAANSUhEU",     // embedded data URL
            "https://",                                        // incomplete URL
            "example.com/image.png",                           // missing scheme
            "https:// domain .com/photo.jpg",                  // spaces in host
            "https:///photo.jpg",                              // malformed
            "https://evil.com/<script>",                       // unsafe characters
            "https://",                                        // host missing

        ]
        
        let emptyPictureUrls = [
            "",
            " ",
            "     ",
            "\n",
            "\t",
            "\n\n",
            "\t\t",
            " \n \t ",
            "",
            "\r\n",
        ]
        
        for pictureUrl in validPictureUrls {
            #expect(throws: Never.self) {
                try InputValidator.validateString(data: pictureUrl, inputField: InputField.pictureUrl)
            }
        }
        
        for pictureUrl in invalidPictureUrls {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(data: pictureUrl, inputField: InputField.pictureUrl)
            }
        }
        
        for pictureUrl in emptyPictureUrls {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(data: pictureUrl, inputField: InputField.pictureUrl)
            }
        }
        
    }
    
    @Test("Test /users/:userID GET")
    func getUser() async throws {
        let newUser = User(email: "richieflores@gmail.com", firstName: "Richie", lastName: "Flores", username: "cstitans22")
        try await withApp { app in
            try await newUser.save(on: app.db)
            let newUserID = newUser.id?.uuidString ?? "id_missing"
            try await app.testing().test(.GET, "users/\(newUserID)", afterResponse: {res in
                print(try res.content.decode(UserDTO.self))
                #expect(res.status == .ok)
            })
        }
    }
}

