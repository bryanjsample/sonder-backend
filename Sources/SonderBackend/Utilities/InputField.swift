//
//  InputField.swift
//  SonderBackend
//
//  Created by Bryan Sample on 11/16/25.
//

enum InputField: Hashable, CustomStringConvertible {
    case email, name, username, pictureUrl
    
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
        }
    }
    
    var regexPattern: String {
        switch self {
        case .email:
            return #"^(?!.*\.\.)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
        case .name:
            return #"^[A-Za-z\u00C0-\u017F]+(?:[ '\u2019-][A-Za-z\u00C0-\u017F]+)*$"#
        case .username:
            return #"^[a-zA-Z][a-zA-Z0-9_]{2,14}$"# // min length of 3 max length of 15
        case .pictureUrl:
            return #"^https?:\/\/[A-Za-z0-9.-]+(?:\/[^\s?#<>%]*)?(?:\?[^\s#<>%]*)?(?:#[^\s<>%]*)?$"#
        }
    }
}
