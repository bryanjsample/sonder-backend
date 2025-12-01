import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "Sonder Homepage"
    }

    // establish endpoints to authorize and onboard users
    try app.register(collection: AuthController())

    // establish all endpoints to engage with a specific user
    try app.register(collection: MeController())

    // establish all endpoints to engage with a group
    try app.register(collection: CirclesController())

    // establish all endpoints to engage with an event
    try app.register(collection: CalendarEventsController())

    // establish all endpoints to engage with a post
    try app.register(collection: PostsController())

    // establish all endpoints to engage with a comment
    try app.register(collection: CommentsController())

}
