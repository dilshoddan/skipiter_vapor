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
    var name: String
    var email: String
    var password: String
    
    init(id: Int? = nil, name: String, email: String, password: String) {
        self.id = id
        self.name = name
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
        let name: String
        let email: String
    }
    
    struct UserId: Content {
        let userId: Int
        let name: String
    }
    
    struct UserFacade: Content {
        let id: Int
        let name: String
        let email: String
    }
    
    struct UserLogin: Content {
        let name: String
        let password: String
    }
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User {
    var skips: Children<User, Skip> {
        return children(\.userID)
    }
    
    var comments: Children<User, Comment> {
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
