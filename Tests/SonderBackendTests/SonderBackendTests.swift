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
        let users = [
            UserDTO(email: "bryanjsample@yahoo.com", firstName: "Bryan", lastName: "Sample", username: "bsizzle", pictureUrl: nil),
            UserDTO(email: "richie.flores@bemidjistate.edu", firstName: "Richie", lastName: "Flores", username: "cstitans22", pictureUrl: "https://lh3.googleusercontent.com/a-/AOh14GiAbCdEf"),
            UserDTO(email: "marie.curie@example.com", firstName: "Marie", lastName: "Curie", username: nil, pictureUrl: "https://cdn.example.com/users/mcurie/avatar.png"),
            UserDTO(email: "chloe.martin@gmail.com", firstName: "Chloë", lastName: "Martin", username: "chloem", pictureUrl: nil),
            UserDTO(email: "angelo.rossi@example.org", firstName: "D’Angelo", lastName: "Rossi", username: "angelor", pictureUrl: "https://lh3.googleusercontent.com/ogw/AAELabc123"),
            UserDTO(email: "anne-marie@domain.co", firstName: "Anne-Marie", lastName: "Dupont", username: nil, pictureUrl: nil),
            UserDTO(email: "jose.alvarez@example.net", firstName: "José", lastName: "Álvarez", username: "jalvarez", pictureUrl: "https://static.domain.io/profiles/u_44/photo.jpg"),
            UserDTO(email: "luc.benoit@example.com", firstName: "Luc", lastName: "Benoît", username: nil, pictureUrl: nil),
            UserDTO(email: "francois.dupont@example.com", firstName: "François", lastName: "Dupont", username: "fdupont", pictureUrl: "https://mycdn.cloudhost.com/avatars/avatar123.png"),
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
        
        try await withApp { app in
            for user in users {
                try await app.testing().test(.POST, "users", beforeRequest: { req in
                    try req.content.encode(user)
                    print("\n\n\(req.content)")
                }, afterResponse: {res in
                    #expect(res.status == .created)
                })
            }
        }
        
    }
    
    @Test("Test /users/:userID GET")
    func getUser() async throws {
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
            User(email: "francois.dupont@example.com", firstName: "François", lastName: "Dupont", username: "fdupont", pictureUrl: "https://mycdn.cloudhost.com/avatars/avatar123"),
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
        
            try await withApp { app in
                for user in users {
                    try await user.save(on: app.db)
                    let userID = user.id?.uuidString ?? "id_missing"
                    try await app.testing().test(.GET, "users/\(userID)", afterResponse: {res in
                        print("\n\n\(try res.content.decode(UserDTO.self))")
                        #expect(res.status == .ok)
                    })
                }
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
            "https://lh3.googleusercontent.com/a-/AOh14GgHijklmn",
            "https://lh3.googleusercontent.com/ogw/AAELabc123?w=200-h=200",
            "https://lh3.googleusercontent.com/p/AF1QipPp9d0YxL1?sz=256",
            "https://lh3.googleusercontent.com/abcd1234=w240-h240",
            "https://ggpht.com/someuser/profile123",

            "https://cdn.example.com/users/12/avatar.png",
            "http://images.site.net/pfps/user123.webp",
            "https://static.domain.io/profiles/u_44/photo.jpg?size=400",
            "https://myapp-images.s3.amazonaws.com/u1/avatar.jpeg",
            "https://sub.domain.org/path/to/img/profile.svg#v2",
        ]
        
        let invalidPictureUrls = [
            "ftp://lh3.googleusercontent.com/a-/AOh14GgHijklmn",     // wrong scheme
            "javascript:alert('xss')",                               // dangerous
            "https://evil.com/<script>",                             // unsafe chars
            "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA",        // data URL not allowed
            "https://",                                              // incomplete
            "example.com/avatar.png",                                // no scheme
            "https:///broken.com/img.png",                           // malformed
            "http://domain.com/image",                               // no extension + non-OAuth
            "https://domain.com/path with spaces/photo.png",         // spaces
            "https://domain.com/img/%ZZ.png",                        // invalid escape

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
    
}

