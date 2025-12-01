//
//  ValidationTests.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/17/25.
//

import Fluent
import Testing
import VaporTesting

@testable import SonderBackend

@Suite("Validation Tests", .serialized)
struct ValidationTests {
    private func withApp(_ test: (Application) async throws -> Void)
        async throws
    {
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
            "plainaddress",  // missing '@' completely
            "@missingusername.com",  // no local part before '@'
            "missingatsign.com",  // missing '@'
            "username@.com",  // domain cannot start with a dot; fails [a-zA-Z0-9.-]+
            "username@domain",  // missing TLD; regex requires \.[A-Za-z]{2,}
            "username@domain..com",  // contains consecutive dots; blocked by negative lookahead (?!.*\.\.)
            "user name@domain.com",  // contains space; not allowed in local part
            "user<script>@gmail.com",  // '<' and '>' not allowed in local part or domain
            "user\"quote\"@gmail.com",  // quotes not allowed in local part per your regex
            "line\nbreak@domain.com",  // newline not allowed; local part must match [a-zA-Z0-9._%+-]+
            "user()@gmail.com",  // parentheses not allowed in local part
            "user@@domain.com",  // two '@' signs; regex expects exactly one
            "skibidi totilet bryan jsame",  // not an email format at all; missing '@' and domain
            "SELECT * FROM vapor",  // not an email; fails entirely and contains spaces + SQL characters
            "scd2999045.1233422123@yahoo.com/sckiii   ",  // contains slash and trailing spaces; path segments not allowed

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
                try InputValidator.validateString(
                    data: email,
                    inputField: InputField.email
                )
            }
        }

        for email in invalidEmails {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: email,
                    inputField: InputField.email
                )
            }
        }

        for email in emptyEmails {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: email,
                    inputField: InputField.email
                )
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
            "O’Connor",
        ]

        let invalidNames = [
            "John  Smith",  // double space not allowed, regex allows only a single [ '-’] between name parts
            "John_Smith",  // underscore not in allowed set [ '-’]
            "Jane@",  // '@' not allowed, only letters + [ '-’]
            "123Bryan",  // cannot start with digits, must start with A–Z or accented letters
            "Bryan123",  // trailing digits not allowed
            "Anne--Marie",  // double hyphen not allowed, only single [ '-’] separator allowed
            "Jean—Luc",  // em-dash (—) not included; only ASCII hyphen (-) allowed
            "O’’Connor",  // double apostrophe; the pattern only allows ONE [ '\u2019-] separator at a time
            "O’",  // trailing separator not followed by letters (requires letters after the separator)
            "'Bryan",  // cannot start with a separator, must start with a letter
            "Bryan-",  // cannot end with separator, must end in a letter
            "Ma!rk",  // '!' not allowed, only letters + allowed separators
            "Élodie#",  // '#' not allowed
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
            "\r\n",
        ]

        for name in validNames {
            #expect(throws: Never.self) {
                try InputValidator.validateString(
                    data: name,
                    inputField: InputField.name
                )
            }
        }

        for name in invalidNames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: name,
                    inputField: InputField.name
                )
            }
        }

        for name in emptyNames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: name,
                    inputField: InputField.name
                )
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
            "1bryan",  // starts with a digit
            "_bryan",  // starts with underscore; must start with a letter
            "ab",  // too short (< 3 characters)
            "averylongusernameexceeds",  // too long (> 15 characters)
            "john-doe",  // hyphens not allowed
            "john.doe",  // dots not allowed
            "john doe",  // spaces not allowed
            "j@ne_doe",  // '@' symbol not allowed
            "br!an",  // '!' symbol not allowed
            "álex123",  // non-ASCII letter; regex only allows A–Z and a–z
            "user__name__",  // trailing underscores allowed, but length exceeds 15 chars
            "user\nname",  // newline not allowed
            "user\tname",  // tab not allowed
            "   ",  // whitespace-only, fails entirely
            "",  // empty string
            "Jo",  // length only 2 chars; must be at least 3
            "Username_ThatIsWayTooLong",  // well beyond 15 chars
            "Jane*Doe",  // '*' not allowed
            "test()",  // parentheses not allowed
            "dev<>dev",  // angle brackets not allowed
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
                try InputValidator.validateString(
                    data: username,
                    inputField: InputField.username
                )
            }
        }

        for username in invalidUsernames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: username,
                    inputField: InputField.username
                )
            }
        }

        for username in emptyUsernames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: username,
                    inputField: InputField.username
                )
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
            "https://sub.domain.org/path/to/img/profile.svg#v2",
        ]

        let invalidPictureUrls = [
            "ftp://example.com/avatar.png",  // invalid scheme (ftp not allowed)
            "https://",  // missing host
            "example.com/image.png",  // missing scheme (must start with http/https)
            "http://exa mple.com/img.png",  // space inside hostname not allowed
            "https://domain.com/img/%ZZ.png",  // '%' not allowed anywhere in path
            "https:///broken.com/img.png",  // malformed URL (extra slashes after scheme)
            "http://domain.com/<script>",  // '<' and '>' are forbidden
            "https://domain.com/img photo.png",  // space in path not allowed
            "https://domain.com/img/\nphoto.png",  // newline not allowed
            "https://domain.com/img/\tavatar.png",  // tab not allowed
            "https://domain.com/img/photo?.png",  // '?' cannot appear inside path except at query start
            "https://domain.com/img/photo#frag#2",  // second '#' illegal inside fragment
            "https://domain.com/img/photo.png#<>",  // '<' and '>' not allowed in fragment
            "javascript:alert(1)",  // non-URL scheme rejected
            "data:image/png;base64,AAAA",  // data: URLs not allowed
            "https://domain.com/img/photo.png%",  // '%' not allowed at end or anywhere
            "http://[::1]/image.png",  // IPv6 literal not matched by your hostname pattern
            "https://domain..com/img.png",  // double dot in hostname invalid per your host rules
            "https://-domain.com/img.png",  // hostname cannot begin with hyphen

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
                try InputValidator.validateString(
                    data: pictureUrl,
                    inputField: InputField.pictureUrl
                )
            }
        }

        for pictureUrl in invalidPictureUrls {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: pictureUrl,
                    inputField: InputField.pictureUrl
                )
            }
        }

        for pictureUrl in emptyPictureUrls {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: pictureUrl,
                    inputField: InputField.pictureUrl
                )
            }
        }

    }

    @Test("Test title validation on array of titles")
    func validateTitles() async throws {
        let validCircleNames = [
            "CircleOne",
            "The Great Circle",
            "A2Z Community",
            "Circle 123",
            "MyCircleName1234567890123456",  // 26 chars
            "AB",  // minimum length 2
            "A Very Long Circle Name 30chars!!".prefix(30).description,  // exactly 30 chars
        ]

        let invalidCircleNames = [
            "A",  // too short (1 char)
            "",  // empty
            "ThisCircleNameIsWayTooLongToBeValidBecauseItExceedsThirtyCharacters",
            "!Circle@",  // forbidden characters ! @
            "Circle#",  // forbidden character #
            "Circle$",  // forbidden character $
            "Circle%",  // forbidden character %
            "Circle^",  // forbidden character ^
            "Circle*",  // forbidden character *
            "Circle+",  // forbidden character +
            "Circle=",  // forbidden character =
            "Circle{",  // forbidden character {
            "Circle}",  // forbidden character }
            "Circle\\",  // forbidden character \
            "Circle~",  // forbidden character ~
            "Circle`",  // forbidden character `
            " ",  // only space
            "  ",  // multiple spaces only
            "\t",  // tab character
            "\n",  // newline
        ]

        let emptyCircleNames = [
            "",
            " ",
            "\t",
            "\n",
            "     ",
            "\n\n\n",
            "\t\t\t",
            " \n \t ",
            "\r\n",
        ]

        for circleName in validCircleNames {
            #expect(throws: Never.self) {
                try InputValidator.validateString(
                    data: circleName,
                    inputField: InputField.title
                )
            }

        }

        for circleName in invalidCircleNames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: circleName,
                    inputField: InputField.title
                )
            }
        }

        for circleName in emptyCircleNames {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: circleName,
                    inputField: InputField.title
                )
            }
        }
    }

    @Test("Test description validation on array of descriptions")
    func validateDescriptions() async throws {
        let validDescriptions = [
            "This is a simple description.",
            "Another description with numbers 123 and symbols allowed - comma, period.",
            String(repeating: "a", count: 2),  // minimum length 2
            String(repeating: "a", count: 150),  // maximum length 150
            "Circle description with emojis 😊🚀",
            "Multi-line description\nWith newline",
            "Description with - dashes and 'quotes', and periods.",
            "Description that is exactly 150 characters long "
                + String(repeating: "a", count: 100),
        ]

        let invalidDescriptions = [
            "",  // empty
            "a",  // too short (1 char)
            String(repeating: "a", count: 151),  // too long (151 chars)
            "<script>alert('xss')</script>",  // forbidden tags
            "{some} description",  // forbidden characters {}
            "Description with % percent",  // forbidden character %
            "Description with ; semicolon",  // forbidden character ;
            "Description with \\ backslash",  // forbidden character \
            "Description with < and >",  // forbidden < and >
            "\t",  // only tab
            "\n",  // only newline
            "  ",  // only spaces
            "   \n\t  ",  // whitespace only
        ]

        let emptyDescriptions = [
            "",
            " ",
            "\t",
            "\n",
            "     ",
            "\n\n\n",
            "\t\t\t",
            " \n \t ",
            "\r\n",
        ]

        for desc in validDescriptions {
            #expect(throws: Never.self) {
                try InputValidator.validateString(
                    data: desc,
                    inputField: InputField.description
                )
            }
        }

        for desc in invalidDescriptions {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: desc,
                    inputField: InputField.description
                )
            }
        }

        for desc in emptyDescriptions {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: desc,
                    inputField: InputField.description
                )
            }
        }
    }

    @Test("Test text block validation on array of text chunks")
    func validateTextBlock() async throws {
        let validPostContents = [
            "Hello world! This is a simple post content.",
            "Here's some multi-line content:\nLine two.\nLine three.",
            "Emoji supported 🚀🔥😊",
            "Content with punctuation, commas, periods... and more!",
            "1234567890 numbers included",
            "Mix of letters, numbers 123, and symbols like - ' \" ! ?",
            String(repeating: "a", count: 1),  // 1 character content
            String(repeating: "a", count: 500),  // long content (assuming no max length restriction here)
            "Newlines\nTabs\tand spaces   ",
            "Content with URL http://example.com",
        ]

        let invalidPostContents = [
            "",
            " ",
            "\n",
            "\t",
            "   ",
            "\n\n",
            "\t\t",
            " \n \t ",
            "<script>alert('XSS')</script>",
            "Malicious {code} attempt",
            "Bad character ; semicolon",
            "Illegal % percent sign",
            "Backslash \\ character",
            "Content with <> angle brackets",
        ]

        for content in validPostContents {
            #expect(throws: Never.self) {
                try InputValidator.validateString(
                    data: content,
                    inputField: InputField.textBlock
                )
            }
        }

        for content in invalidPostContents {
            #expect(throws: ValidationError.self) {
                try InputValidator.validateString(
                    data: content,
                    inputField: InputField.textBlock
                )
            }
        }
    }
}
