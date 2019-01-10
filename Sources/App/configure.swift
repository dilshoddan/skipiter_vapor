import FluentSQLite
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config,
                      _ env: inout Environment,
                      _ services: inout Services) throws {
    
    try services.register(AuthenticationProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    
    let leafProvider = LeafProvider()    // added
    try services.register(leafProvider)  // added
    
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    try services.register(FluentSQLiteProvider())
    var databases = DatabasesConfig()
    try databases.add(database: SQLiteDatabase(storage: .file(path: "skipiter_web_db")), as: .sqlite)
    //.file(path: "skipiter_web_db")  - permanent will create a db file on disk
    //.memory ~ temporary will be destroyed on re-run
    services.register(databases)
    
    
    
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .sqlite)
    migrations.add(model: Token.self, database: .sqlite)
    migrations.add(model: Skip.self, database: .sqlite)
    services.register(migrations)
    
    
}


///CHANGE LISTENING PORT TO 8001
//    let myService = NIOServerConfig.default(port: 8001)
//    services.register(myService)
