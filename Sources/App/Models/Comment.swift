//
//  Skip.swift
//  App
//
//  Created by Admin on 1/9/19.
//

import FluentSQLite
import Vapor

final class Comment: SQLiteModel {
    var id: Int?
    var text: String
    var date: Date
    var userID: User.ID
    var skipID: Skip.ID
    
    init(id: Int? = nil, text: String, date: Date = Date() , userID: User.ID, skipID: Skip.ID) {
        self.id = id
        self.text = text
        self.date = date
        self.userID = userID
        self.skipID = skipID
    }
    
    
}

extension Comment: Content {}
extension Comment: Migration {}
extension Comment: Parameter {}

extension Comment {
    struct CommentForm: Content {
        var id: Int?
        var text: String
        var date: Date?
        var userName: String?
        var skipID: Int
    }
    
}

extension Comment {
    var user: Parent<Comment, User> {
        return parent(\.userID)
    }
    
    var skip: Parent<Comment, Skip> {
        return parent(\.skipID)
    }
}
