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
                        return Skip.SkipForm(id: s.id, text: s.text, date: s.date, userName: userName)
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
                    skipForms.append(Skip.SkipForm(id: skip.id, text: skip.text, date: skip.date, userName: user.name))
                }
                return skipForms
        }
    }
    
    
    
    func listAllSkips(_ req: Request) throws -> Future<[Skip.SkipForm]> {
        _ = try req.requireAuthenticated(User.self)
        return Skip.query(on: req).join(\User.id, to: \Skip.userID).alsoDecode(User.self).all().map { results in
            var skipForms : [Skip.SkipForm] = []
            for result in results {
                skipForms.append(Skip.SkipForm(id: result.0.id, text: result.0.text, date: result.0.date, userName: result.1.name))
            }
            return skipForms
            
        }
        
    }
    
    func skips(_ req: Request) throws -> Future<[Skip.SkipForm]> {
        _ = try req.requireAuthenticated(User.self)
        return Skip.query(on: req).join(\User.id, to: \Skip.userID).alsoDecode(User.self).all().map { results in
            var skipForms : [Skip.SkipForm] = []
            for result in results {
                skipForms.append(Skip.SkipForm(id: result.0.id, text: result.0.text, date: result.0.date, userName: result.1.name))
            }
            return skipForms
            
        }
        
    }
    
    
    func deleteASkip(_ req: Request) throws -> Future<Response> {
        _ = try req.requireAuthenticated(User.self)
        return try req.content.decode(Skip.SkipForm.self).flatMap { skipForm in
            return Skip.find(skipForm.id!, on: req).flatMap { skip in
                if let skip = skip {
                    return skip.delete(on: req).map { _ in
                        return req.response(http: HTTPResponse(status: .ok))
                        
                    }
                } else {
                    throw Abort(HTTPStatus.expectationFailed, reason: "Skip not found")
                }
                
            }
        }
    }
    
    
}


//User.query(on: req).filter(\User.id, .equal, skip.userID).first().map { user in return user}
// var skipForms : [Skip.SkipForm] = []
//for skip in skips {
//    let user: User = User.find(skip.userID, on: req)
//    //                        . { user -> User.UserPublic in
//    //                        return User.UserPublic(id: (user?.id)!, name: (user?.name)!, email: (user?.email)!)
//
//    //}
//    skipForms.append(Skip.SkipForm(text: skip.text, date: skip.date, userName: user.name))
//
//}
//return skipForms
