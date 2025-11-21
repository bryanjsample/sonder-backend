//
//  InputField.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/16/25.
//

enum InputField: Hashable, CustomStringConvertible {
    case email, name, username, pictureUrl, title, description, textBlock
    
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
        case .title:
            return "title"
        case .description:
            return "description"
        case .textBlock:
            return "textBlock"
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
            return #"^[A-Za-z\u00C0-\u017F]+(?:[ '\u2019-][A-Za-z\u00C0-\u017F]+)*$"#
        case .username:
            return #"^(?!.*__)[a-zA-Z][a-zA-Z0-9_]{2,14}$"# // min length of 3 max length of 15
        case .pictureUrl:
            return #"^https?:\/\/[A-Za-z0-9]+(?:\.[A-Za-z0-9]+)*+(?:\/[^\s?#<>%]+)*\.(?:jpg|jpeg|png|gif|webp|bmp|svg)(?:\?[^\s#<>%]*)?(?:#[^\s<>%]*)?$"#
        case .title:
            return #"^[^\t\n\r@#$%<>^*+=;{}\\`~]{2,30}$"#
        case .description:
            return #"^[^@#$%<>;{}\\]{2,150}$"#
        case .textBlock:
            return #"^(?s)[^\u0000-\u0008\u000B\u000C\u000E-\u001F@#$%<>;{}\\]{1,1000}$"#
            

        }
    }
}

