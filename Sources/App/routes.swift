import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let userController = UserController()
    let skipController = SkipController()
    
    router.post("register", use: userController.register)
    router.post("login", use: userController.login)
    
    let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
    let authedRoutes = router.grouped(tokenAuthenticationMiddleware)
    authedRoutes.get("profile", use: userController.profile)
    authedRoutes.get("logout", use: userController.logout)
    authedRoutes.get("deleteSkips", use: userController.deleteSkips)
    authedRoutes.get("listSkips", use: userController.listSkips)
    authedRoutes.post("skip", use: skipController.create)
    
    
    //router.post("skip", use: skipController.create)
    
}







/* without Token Authentication
 
 router.get("json") { req in
 return Person(name: "Dilshod", age: 32)
 }
 
 router.get("view") { req -> Future<View> in
 return try req.view().render("welcome")
 }
 
 router.get("RawData") { req -> Future<View> in
 let data = ["name": "Dilshod", "age": "32"]
 return try req.view().render("whoAmI", data)
 }
 
 router.get("person") { req -> Future<View> in
 let person = Person(name: "Dilshod", age: 32)
 return try req.view().render("whoAmI", person)
 }
 
 
 let userController = UserController()
 router.get("users", use: userController.list)
 
 
 router.post("users", use: userController.create)
 
 router.get("usersJSON", use: userController.listJSON)
 
 //call the post route on terminal like below or use postman or paw
 //curl -H "Content-Type: application/json" -X POST -d '{"userName": "Fiona", "age": 23}' http://localhost:8080/usersJSON
 router.post("usersJSON", use: userController.createJSON)
 
 //curl -H "Content-Type: application/json" -X PATCH -d '{"username":"midna"}' http://localhost:8080/users/1 where 1 is user id
 router.patch("usersJSON", User.parameter, use: userController.updateJSON)
 
 router.delete("usersJSON", User.parameter, use: userController.deleteJSON)
 
 */


//struct Person: Content {
//    var name: String
//    var age: Int
//}


//    router.get("users") { req -> Future<View> in
//        return User.query(on: req).all().flatMap { users in
//            let data = ["userList": users]
//            return try req.view().render("usersView", data)
//        }
//
//    }

//    router.post("users") { req -> Future<Response> in
//        return try req.content.decode(User.self).flatMap { user in
//            return user.save(on: req).map { _ in
//                return req.redirect(to: "users")
//            }
//        }
//    }
