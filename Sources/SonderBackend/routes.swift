import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Sonder Homepage"
    }
    
    // establish all endpoints to engage with a group
    try app.register(collection: CirclesController())
    
    // establishes all endpoints to engage with a user
    try app.register(collection: UsersController())
    
    // establish all endpoints to engage with an event
    try app.register(collection: CalendarEventsController())
    
    // establish all endpoints to engage with a post
    try app.register(collection: PostsController())
    
    // establish all endpoints to engage with a comment
    try app.register(collection: CommentsController())
    
    // authorization endpoints
    try app.register(collection: AuthController())
    
}
