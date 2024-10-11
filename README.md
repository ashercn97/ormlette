# ormlette

Ormlette is a delightful ORM (?) for Gleam. It's features include but are not limited to:

- A (pretty awesome) schema DSL
- A powerful query DSL that can be exported to `gleam-cake` Select statements, and used directly with `cake`
- A CLI to automatically generate easy-use types

> Ormlette is currently in the very early stages of development, so advice/feature requests/bug reports are super helpful!

> [!NOTE]
> THESE DOCS ARE NOT COMPLETE YET!

## Schema DSL

The schema DSL is the main way to define your database schema within ormlette. It allows you to define tables, columns, and relationships between tables.

Here is what it looks like:

```gleam
import ormlette/schema/create as c

pub fn users_table() {
  c.define_table("users", [
    c.serial("id") |> c.primary,
    c.text("name") |> c.nullable,
  ])
}
```

To generate everything you need to work with databases, run `gleam run -m ormlette` and look in the `src/eggs` directory.

## Query DSL

The query DSL is the main way to build queries with ormlette. It allows you to select, insert, update, and delete data from your database. It is **heavily** based on `gleam-cake`, and uses it under the hood. Luckily, if you need to use features that `cake` supports and ormlette doesn't, you can just `q.export` the query, and use it directly with `cake`!

Here is what the query DSL looks like:

```gleam
q.from_table(posts_table)
    |> q.inner_join(users_table)
    |> q.inner_join(users_table)
    |> q.select(["users.name", "posts.id", "posts.user_id"])
    |> q.sql
    |> io.debug()
    |> run.run(db, users_posts_decoder.continuation) // this decoder is generated for us!
    |> io.debug
```

Here is the magical part: the decoder puts the results into a type perfectly, every time. No matter what you select, how you select it, the order, etc., it is all put into the correct type, every time. All with one command!
