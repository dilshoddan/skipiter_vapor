//
//  Skip.swift
//  App
//
//  Created by Admin on 1/9/19.
//

import FluentSQLite
import Vapor

final class Skip: SQLiteModel {
    var id: Int?
    var text: String
    var date: Date
    var userID: User.ID
    
    init(id: Int? = nil, text: String, date: Date = Date() , userID: User.ID) {
        self.id = id
        self.text = text
        self.date = date
        self.userID = userID
    }
    
    
}

extension Skip: Content {}
extension Skip: Migration {}
extension Skip: Parameter {}

extension Skip {
    struct SkipForm: Content {
        var text: String
    }
}

extension Skip {
    var user: Parent<Skip, User> {
        return parent(\.userID)
    }
}
