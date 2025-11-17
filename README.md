# SonderBackend

⚙️ Backend Architecture for Sonder Application

## Getting Started

To build the project using the Swift Package Manager, run the following command in the terminal from the root of the project:
```bash
swift build
```

To run the project and start the server, use the following command:
```bash
swift run
```

To execute tests, use the following command:
```bash
swift test
```

### See more

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community](https://github.com/vapor-community)

---

## Endpoints

`serverhost/users`

- POST

`serverhost/users/{userID}`

- GET
- PATCH
- DELETE

`serverhost/circles`

- POST

`serverhost/circles/{circleID}`

- GET
- PATCH
- DELETE

`serverhost/circles/{circleID}/events`

- GET
- POST

`serverhost/circles/{circleID}/events/{eventID}`

- GET
- PATCH
- DELETE

`serverhost/circles/{circleID}/posts`

- GET
- POST

`serverhost/circles/{circleID}/posts/{postID}`

- GET
- PATCH
- DELETE

`serverhost/circles/{circleID}/posts/{postID}/comments`

- GET
- POST

`serverhost/circles/{circleID}/posts/{postID}/comments/{commentID}`

- GET
- PATCH
- DELETE

---

## Database Schema

```txt
 Schema |        Name        | Type  
--------+--------------------+-------
 public | _fluent_migrations | table 
 public | circles            | table 
 public | comments           | table 
 public | events             | table 
 public | posts              | table 
 public | users              | table 
```

### Users

```txt
                           Table "public.users"
    Column     |           Type           | Collation | Nullable | Default
---------------+--------------------------+-----------+----------+---------
 id            | uuid                     |           | not null |
 email         | text                     |           | not null |
 first_name    | text                     |           | not null |
 last_name     | text                     |           | not null |
 circle_id     | uuid                     |           |          |
 username      | text                     |           |          |
 picture_url   | text                     |           |          |
 created_at    | timestamp with time zone |           |          |
 last_modified | timestamp with time zone |           |          |
Indexes:
    "users_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "users_circle_id_fkey" FOREIGN KEY (circle_id) REFERENCES circles(id)
Referenced by:
    TABLE "comments" CONSTRAINT "comments_author_id_fkey" FOREIGN KEY (author_id) REFERENCES users(id)
    TABLE "events" CONSTRAINT "events_host_id_fkey" FOREIGN KEY (host_id) REFERENCES users(id)
    TABLE "posts" CONSTRAINT "posts_author_id_fkey" FOREIGN KEY (author_id) REFERENCES users(id)
```

### Circles

```txt
                          Table "public.circles"
    Column     |           Type           | Collation | Nullable | Default
---------------+--------------------------+-----------+----------+---------
 id            | uuid                     |           | not null |
 name          | text                     |           | not null |
 description   | text                     |           | not null |
 picture_url   | text                     |           |          |
 created_at    | timestamp with time zone |           |          |
 last_modified | timestamp with time zone |           |          |
Indexes:
    "circles_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "events" CONSTRAINT "events_circle_id_fkey" FOREIGN KEY (circle_id) REFERENCES circles(id)
    TABLE "posts" CONSTRAINT "posts_circle_id_fkey" FOREIGN KEY (circle_id) REFERENCES circles(id)
    TABLE "users" CONSTRAINT "users_circle_id_fkey" FOREIGN KEY (circle_id) REFERENCES circles(id)
```

### Events

```txt
                           Table "public.events"
    Column     |           Type           | Collation | Nullable | Default
---------------+--------------------------+-----------+----------+---------
 id            | uuid                     |           | not null |
 host_id       | uuid                     |           | not null |
 circle_id     | uuid                     |           | not null |
 title         | text                     |           | not null |
 description   | text                     |           | not null |
 start_time    | timestamp with time zone |           | not null |
 end_time      | timestamp with time zone |           | not null |
 created_at    | timestamp with time zone |           |          |
 last_modified | timestamp with time zone |           |          |
Indexes:
    "events_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "events_circle_id_fkey" FOREIGN KEY (circle_id) REFERENCES circles(id)
    "events_host_id_fkey" FOREIGN KEY (host_id) REFERENCES users(id)
```

### Posts

```txt
                           Table "public.posts"
    Column     |           Type           | Collation | Nullable | Default
---------------+--------------------------+-----------+----------+---------
 id            | uuid                     |           | not null |
 circle_id     | uuid                     |           | not null |
 author_id     | uuid                     |           | not null |
 content       | text                     |           | not null |
 created_at    | timestamp with time zone |           |          |
 last_modified | timestamp with time zone |           |          |
Indexes:
    "posts_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "posts_author_id_fkey" FOREIGN KEY (author_id) REFERENCES users(id)
    "posts_circle_id_fkey" FOREIGN KEY (circle_id) REFERENCES circles(id)
Referenced by:
    TABLE "comments" CONSTRAINT "comments_post_id_fkey" FOREIGN KEY (post_id) REFERENCES posts(id)
```

### Comments

```txt
                          Table "public.comments"
    Column     |           Type           | Collation | Nullable | Default
---------------+--------------------------+-----------+----------+---------
 id            | uuid                     |           | not null |
 post_id       | uuid                     |           | not null |
 author_id     | uuid                     |           | not null |
 content       | text                     |           | not null |
 created_at    | timestamp with time zone |           |          |
 last_modified | timestamp with time zone |           |          |
Indexes:
    "comments_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "comments_author_id_fkey" FOREIGN KEY (author_id) REFERENCES users(id)
    "comments_post_id_fkey" FOREIGN KEY (post_id) REFERENCES posts(id)
```
