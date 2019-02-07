//
//  SkipController.swift
//  App
//
//  Created by Admin on 1/9/19.
//

import Vapor
import FluentSQLite
import Authentication

final class CommentController {
    
    func create(_ req: Request) throws -> Future<Comment.CommentForm> {
        let user = try req.requireAuthenticated(User.self)
        if let userId = user.id {
            return try req.content.decode(Comment.CommentForm.self).flatMap { commentForm in
                
                return Skip.find(commentForm.skipID, on: req).flatMap { skip in
                    guard let skipId = try skip?.requireID() else {
                        throw Abort(.badRequest)
                    }
                    let comment = Comment(
                        text: commentForm.text,
                        userID: userId,
                        skipID: skipId
                    )
                    return comment.save(on: req).map { s in
                        return Comment.CommentForm(id: s.id, text: s.text, date: s.date, userName: user.name, skipID: s.skipID)
                    }
                }
            }
        } else {
            throw Abort(HTTPStatus.unauthorized)
        }
    }
    
    
    func listCommentsForSkip(_ req: Request) throws -> Future<[Comment.CommentForm]> {
        let _ = try req.requireAuthenticated(User.self)
        return try req.content.decode(Skip.SkipId.self).flatMap { skipId in
            return Comment
                .query(on: req)
                .filter(\Comment.skipID, .equal, skipId.skipId)
                .join(\User.id, to: \Comment.userID).alsoDecode(User.self).all().map { comments in
                    var commentForms : [Comment.CommentForm] = []
                    for comment in comments {
                        commentForms.append(Comment.CommentForm(id: comment.0.id,
                                                                text: comment.0.text,
                                                                date: comment.0.date,
                                                                userName: comment.1.name,
                                                                skipID: comment.0.skipID))
                        
                    }
                    return commentForms
            }
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
