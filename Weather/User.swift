//
//  User.swift
//  NoteApp
//
//  Created by frank on 2020/6/29.
//  Copyright © 2020 Frank. All rights reserved.
//
import Foundation
import AuthenticationServices

struct User  : Codable {
//    func encode(with coder: NSCoder) {
//        coder.encode(id, forKey: "id")
//        coder.encode(firstName, forKey: "firstName")
//        coder.encode(lastName, forKey: "lastName")
//        coder.encode(email, forKey: "email")
//    }
//
//    required init?(coder: NSCoder) {
//
//        self.id = coder.decodeObject(forKey: "id") as! String
//        self.firstName = coder.decodeObject(forKey: "firstName") as? String
//        self.lastName = coder.decodeObject(forKey: "lastName") as? String
//        self.email = coder.decodeObject(forKey: "email") as? String
//    }
    
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    
    init(credentials: ASAuthorizationAppleIDCredential) {
        self.id = credentials.user
        self.firstName = credentials.fullName?.givenName ?? ""
        self.lastName = credentials.fullName?.familyName ?? ""
        self.email = credentials.email ?? ""
    }
}

extension User: CustomDebugStringConvertible {
    var debugDescription: String {
        return """
        ID: \(id)
        First Name: \(firstName)
        Last Name: \(lastName)
        Email: \(email)
        """
    }
}
