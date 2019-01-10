//
//  User.swift
//  App
//
//  Created by Admin on 1/8/19.
//

import FluentSQLite
import Vapor
import Authentication

final class User: SQLiteModel {
    var id: Int?
    var email: String
    var password: String
    
    init(id: Int? = nil, email: String, password: String) {
        self.id = id
        self.email = email
        self.password = password
    }
    
    
    
}

extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

extension User {
    struct UserPublic: Content {
        let id: Int
        let email: String
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User {
    var skips: Children<User, Skip> {
        return children(\.userID)
    }
}



/*
 init(id: Int? = nil, userName: String, password: String, email: String, age: Int) {
 self.id = id
 self.userName = userName
 self.email = email
 self.password = password
 self.age = age
 }
 */
