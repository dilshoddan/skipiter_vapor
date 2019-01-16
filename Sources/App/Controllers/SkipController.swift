//
//  SkipController.swift
//  App
//
//  Created by Admin on 1/9/19.
//

import Vapor
import FluentSQLite
import Authentication

final class SkipController {
    
    func create(_ req: Request) throws -> Future<Skip.SkipForm> {
        let user = try req.requireAuthenticated(User.self)
        if let userId = user.id {
            return try req.content.decode(Skip.SkipForm.self).flatMap { skipForm in
                //this is extra remove it later
                return User.find(userId, on: req).flatMap { user in
                    guard let userId = try user?.requireID(), let userName = user?.name else {
                        throw Abort(.badRequest)
                    }
                    let newSkip = Skip(
                        text: skipForm.text,
                        userID: userId
                    )
                    return newSkip.save(on: req).map { s in
                        return Skip.SkipForm(text: s.text, date: s.date, userName: userName)
                    }
                }
            }
        } else {
            throw Abort(HTTPStatus.unauthorized)
        }
    }
    
    
    func listSkips(_ req: Request) throws -> Future<[Skip.SkipForm]> {
        let user = try req.requireAuthenticated(User.self)
        return try Skip
            .query(on: req)
            .filter(\Skip.userID, .equal, user.requireID())
            .all().map { skips in
                var skipForms : [Skip.SkipForm] = []
                for skip in skips {
                    skipForms.append(Skip.SkipForm(text: skip.text, date: skip.date, userName: user.name))
                }
                return skipForms
        }
    }
    
    
    
    func listAllSkips(_ req: Request) throws -> Future<[Skip.SkipForm]> {
        _ = try req.requireAuthenticated(User.self)
        return Skip
            .query(on: req)
            .all().map { skips in
                var skipForms : [Skip.SkipForm] = []
                for skip in skips {
                    User
                        .query(on: req)
                        .filter(\User.id, .equal, skip.userID).first().map { user in
                            skipForms.append(Skip.SkipForm(text: skip.text, date: skip.date, userName: user?.name))
                    }
                    
                }
                return skipForms
        }
    }
}


