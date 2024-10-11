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
    |> q.select(["users.name", "posts.id", "posts.user_id"])
    |> q.sql
    |> io.debug()
    |> run.run(db, users_posts_decoder.continuation) // this decoder is generated for us!
    |> io.debug
```

Here is the magical part: the decoder puts the results into a type perfectly, every time. No matter what you select, how you select it, the order, etc., it is all put into the correct type, every time. All with one command!

## CLI

The CLI is how you generate our "universal decoders," decoder types, and usage types. So what are all of these?

### Universal Decoders

Universal decoders are just dynamic decoders. The special part, though, is that they allow you to decode queries EVERY time. This means that even if you make two different `select` queries, each with a different order of selected columns, the **same** decoder will work with both queries!

Moreover, it will also automatically generate join types and decoders with NO extra work from you. This means that if you have two tables that are related, there is no issue decoding these dynamic values! Pretty epic.

### Decoder Types

Decoder types are what the dynamic decoders decode the dynamic values into. This means that you will be able to reference columns of a row, without needing any extra work, and with them being the type you want!

### Usage Types

Usage types are not strictly necessary to enjoy using `ormlette`. But, (in my opinion) make everything much more pleasent. They gaurentee that you do not
a) miss-spell a column,
b) reference a column that doesn't exist, and
c) provide code completeion for the different columns!

Usage types allow you to do something like:

```gleam
import eggs/tables as t

t.users().id // this gets the users table id column and turns it into something that can be used in a seelct column, for instance
```

They are automatically generated, and in my opinion are worth using!
