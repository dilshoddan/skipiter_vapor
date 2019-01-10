//
//  UserController.swift
//  App
//
//  Created by Admin on 1/8/19.
//

import Vapor
import Crypto
import Random
import FluentSQLite

final class UserController {
    
    func register(_ req: Request) throws -> Future<User.UserPublic> {
        return try req.content.decode(User.self).flatMap { user in
            let hasher = try req.make(BCryptDigest.self)
            let passwordHashed = try hasher.hash(user.password)
            let newUser = User(email: user.email, password: passwordHashed)
            
            return newUser.save(on: req).map { storedUser in
                return User.UserPublic(
                    id: try storedUser.requireID(),
                    email: storedUser.email
                )
            }
        }
    }
    
    func login(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap { user in
            return User.query(on: req).filter(\.email == user.email).first().flatMap { fetchedUser in
                guard let existingUser = fetchedUser else {
                    throw Abort(HTTPStatus.notFound)
                }
                
                let hasher = try req.make(BCryptDigest.self)
                if try hasher.verify(user.password, created: existingUser.password) {
                    return try Token
                        .query(on: req)
                        .filter(\Token.userId, .equal, existingUser.requireID())
                        .delete()
                        .flatMap { _ in
                            let tokenString = try URandom().generateData(count: 32).base64EncodedString()
                            let token = try Token(token: tokenString, userId: existingUser.requireID())
                            return token.save(on: req)
                    }
                } else {
                    throw Abort(HTTPStatus.unauthorized)
                }
            }
        }
    }
    
    func profile(_ req: Request) throws -> Future<String> {
        let user = try req.requireAuthenticated(User.self)
        return req.future("Welcome \(user.email)")
    }
    
    func logout(_ req: Request) throws -> Future<HTTPResponse> {
        let user = try req.requireAuthenticated(User.self)
        return try Token
            .query(on: req)
            .filter(\Token.userId, .equal, user.requireID())
            .delete()
            .transform(to: HTTPResponse(status: .ok))
    }
    
    func listSkips(_ req: Request) throws -> Future<[Skip.SkipForm]> {
        let user = try req.requireAuthenticated(User.self)
        return try Skip
            .query(on: req)
            .filter(\Skip.userID, .equal, user.requireID())
            .all().map { skips in
                var skipForms : [Skip.SkipForm] = []
                for skip in skips {
                    skipForms.append(Skip.SkipForm(text: skip.text))
                }
            return skipForms
        }
    }
    
    func deleteSkips(_ req: Request) throws -> Future<Response> {
        let user = try req.requireAuthenticated(User.self)
        if let userId = user.id {
            return User.find(userId, on: req).flatMap { user in
                if let user = user {
                    return try user.skips.query(on: req).delete().map { _ in
                        return req.response(http: HTTPResponse(status: .ok))
                    
                    }
                } else {
                    throw Abort(HTTPStatus.expectationFailed, reason: "User not found on DB")
                }
            }
        } else {
            throw Abort(HTTPStatus.unauthorized)
        }
    }
    
}






/*
 
 let user = try req.requireAuthenticated(User.self)
 return User.find(userId, on: req).flatMap { user in
 guard let userId = try user?.requireID() else {
 throw Abort(.badRequest)
 }
 return try user.skips.query(on: req).delete().map { _ in
 return req.redirect(to: "/users")
 
 }
 }
 } else {
 throw Abort(HTTPStatus.unauthorized)
 }
 
 
 func list(_ req: Request) throws -> Future<View> {
 return User.query(on: req).all().flatMap { users in
 let data = ["userList": users]
 return try req.view().render("usersView", data)
 }
 }
 
 func create(_ req: Request) throws -> Future<Response> {
 return try req.content.decode(User.self).flatMap { user in
 return user.save(on: req).map { _ in
 return req.redirect(to: "users")
 }
 }
 }
 
 
 func listJSON(_ req: Request) throws -> Future<[User]> {
 return User.query(on: req).all()
 }
 
 func createJSON(_ req: Request) throws -> Future<User> {
 return try req.content.decode(User.self).flatMap { user in
 return user.save(on: req)
 }
 }
 
 func updateJSON(_ req: Request) throws -> Future<User> {
 return try req.parameters.next(User.self).flatMap { user in
 return try req.content.decode(User.self).flatMap { newUser in
 user.userName = newUser.userName
 user.age = newUser.age
 return user.save(on: req)
 }
 }
 }
 
 func deleteJSON(_ req: Request) throws -> Future<HTTPStatus> {
 return try req.parameters.next(User.self).flatMap { user in
 return user.delete(on: req)
 }.transform(to: .ok)
 }
 
 */
