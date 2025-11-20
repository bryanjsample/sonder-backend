//
//  InputField.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/16/25.
//

enum InputField: Hashable, CustomStringConvertible {
    case email, name, username, pictureUrl, circleName, circleDescription, postContent
    
    var description: String {
        switch self {
        case .email:
            return "email"
        case .name:
            return "name"
        case .username:
            return "username"
        case .pictureUrl:
            return "pictureUrl"
        case .circleName:
            return "circleName"
        case .circleDescription:
            return "circleDescription"
        case .postContent:
            return "postContent"
        }
    }
    
    var regexPattern: String {
        switch self {
        case .email:
            /*
             "plainaddress",                          // missing '@' completely
             "@missingusername.com",                  // no local part before '@'
             "missingatsign.com",                     // missing '@'
             "username@.com",                         // domain cannot start with a dot; fails [a-zA-Z0-9.-]+
             "username@domain",                       // missing TLD; regex requires \.[A-Za-z]{2,}
             "username@domain..com",                  // contains consecutive dots; blocked by negative lookahead (?!.*\.\.)
             "user name@domain.com",                  // contains space; not allowed in local part
             "user<script>@gmail.com",                // '<' and '>' not allowed in local part or domain
             "user\"quote\"@gmail.com",               // quotes not allowed in local part per your regex
             "line\nbreak@domain.com",                // newline not allowed; local part must match [a-zA-Z0-9._%+-]+
             "user()@gmail.com",                      // parentheses not allowed in local part
             "user@@domain.com",                      // two '@' signs; regex expects exactly one
             "skibidi totilet bryan jsame",           // not an email format at all; missing '@' and domain
             "SELECT * FROM vapor",                   // not an email; fails entirely and contains spaces + SQL characters
             "scd2999045.1233422123@yahoo.com/sckiii   ",   // contains slash and trailing spaces; path segments not allowed
            */
            return #"^(?!.*\.\.)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        case .name:
            /*
             "Br y a n",                // contains multiple internal spaces, pattern only allows ONE separator at a time
             "John  Smith",             // double space not allowed, regex allows only a single [ '-’] between name parts
             "John_Smith",              // underscore not in allowed set [ '-’]
             "Jane@",                   // '@' not allowed, only letters + [ '-’]
             "123Bryan",                // cannot start with digits, must start with A–Z or accented letters
             "Bryan123",                // trailing digits not allowed
             "Anne--Marie",             // double hyphen not allowed, only single [ '-’] separator allowed
             "Jean—Luc",                // em-dash (—) not included; only ASCII hyphen (-) allowed
             "O’’Connor",               // double apostrophe; the pattern only allows ONE [ '\u2019-] separator at a time
             "O’",                      // trailing separator not followed by letters (requires letters after the separator)
             "'Bryan",                  // cannot start with a separator, must start with a letter
             "Bryan-",                  // cannot end with separator, must end in a letter
             "Ma!rk",                   // '!' not allowed, only letters + allowed separators
             "Élodie#",                 // '#' not allowed
            */
            return #"^[A-Za-z\u00C0-\u017F]+(?:[ '\u2019-][A-Za-z\u00C0-\u017F]+)*$"#
        case .username:
            /*
             "1bryan",          // starts with a digit
             "_bryan",          // starts with underscore; must start with a letter
             "ab",              // too short (< 3 characters)
             "averylongusernameexceeds", // too long (> 15 characters)
             "john-doe",        // hyphens not allowed
             "john.doe",        // dots not allowed
             "john doe",        // spaces not allowed
             "j@ne_doe",        // '@' symbol not allowed
             "br!an",           // '!' symbol not allowed
             "álex123",         // non-ASCII letter; regex only allows A–Z and a–z
             "user__name__",    // trailing underscores allowed, but consecutive underscores are not
             "user\nname",      // newline not allowed
             "user\tname",      // tab not allowed
             "   ",             // whitespace-only, fails entirely
             "",                // empty string
             "Jo",              // length only 2 chars; must be at least 3
             "Username_ThatIsWayTooLong", // well beyond 15 chars
             "Jane*Doe",        // '*' not allowed
             "test()",          // parentheses not allowed
             "dev<>dev",        // angle brackets not allowed
            */
            return #"^(?!.*__)[a-zA-Z][a-zA-Z0-9_]{2,14}$"# // min length of 3 max length of 15
        case .pictureUrl:
            /*
             "ftp://example.com/avatar.png",        // invalid scheme (ftp not allowed)
             "https://",                            // missing host
             "example.com/image.png",               // missing scheme (must start with http/https)
             "http://exa mple.com/img.png",         // space inside hostname not allowed
             "https://domain.com/img/%ZZ.png",       // '%' not allowed anywhere in path
             "https:///broken.com/img.png",         // malformed URL (extra slashes after scheme)
             "http://domain.com/<script>",          // '<' and '>' are forbidden
             "https://domain.com/img photo.png",     // space in path not allowed
             "https://domain.com/img/\nphoto.png",   // newline not allowed
             "https://domain.com/img/\tavatar.png",  // tab not allowed
             "https://domain.com/img/photo?.png",    // '?' cannot appear inside path except at query start
             "https://domain.com/img/photo#frag#2",  // second '#' illegal inside fragment
             "https://domain.com/img/photo.png#<>",  // '<' and '>' not allowed in fragment
             "javascript:alert(1)",                  // non-URL scheme rejected
             "data:image/png;base64,AAAA",           // data: URLs not allowed
             "https://domain.com/img/photo.png%",    // '%' not allowed at end or anywhere
             "http://[::1]/image.png",               // IPv6 literal not matched by your hostname pattern
             "https://domain..com/img.png",          // double dot in hostname invalid per your host rules
             "https://-domain.com/img.png",          // hostname cannot begin with hyphen
             "https://domain.com/img/.png",          // path segment starts with '.' which may be allowed in theory but violates your character constraints after splitting
            */
            return #"^https?:\/\/[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)*+(?:\/[^\s?#<>%]+)*\.(?:jpg|jpeg|png|gif|webp|bmp|svg)(?:\?[^\s#<>%]*)?(?:#[^\s<>%]*)?$"#
        case .circleName:
            return #"^[^\t\n\r@#$%<>;{}\\]{2,30}$"#
        case .circleDescription:
            return #"^[^@#$%<>;{}\\]{2,150}$"#
        case .postContent:
            return #"^(?s)[^\u0000-\u0008\u000B\u000C\u000E-\u001F@#$%<>;{}\\]{1,1000}$"#

        }
    }
}
