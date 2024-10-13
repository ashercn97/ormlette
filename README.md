# ormlette

Ormlette is a delightful ORM (?) for Gleam. It's features include but are not limited to:

- A (pretty awesome) schema DSL
- A powerful query DSL that can be exported to `gleam-cake` Select statements, and used directly with `cake`
- A CLI to automatically generate easy-use types, decoders, and more!
- Changesets (like Ecto!)
- Built-in validation library for changesets
- Universal decoders (more on this later!)
- Automatically generated record-to-dict functions


> Ormlette is currently in the very early stages of development, so advice/feature requests/bug reports are super helpful!

> [!NOTE]
> THESE DOCS ARE NOT COMPLETE YET! SOME MIGHT BE OUTDATED, IF SOMETHING DOESNT WORK JUST LEAVE AN ISSUE
> ALSO ALL THE FEATURES ARE NOT HERE YET. SO THIS MIGHT LAG BEHIND THE REAL STATE OF HTE PROJECT FOR A WHILE

## Installation
run `gleam add ormlette` in your project.

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

To generate everything you need to work with databases, there are two commands to run:
first run `gleam run -m ormlette -- meta` which generates some reflection values using Glerd, then run
`gleam run -m ormlette -- orm` and look in the `src/eggs` directory to see everything that was generated!

## Query DSL

The query DSL is the main way to build queries with ormlette. It allows you to select, insert, update, and delete data from your database. It is **heavily** based on `gleam-cake`, and uses it under the hood. Luckily, if you need to use features that `cake` supports and ormlette doesn't, you can just `q.export` the query, and use it directly with `cake`!

Here is what the query DSL looks like:

```gleam
q.from_table(posts_table)
    |> q.inner_join(users_table)
    |> q.select([t.users().id, t.posts().id, "posts.user_id"]) //any one of these work, strings or usage types
    |> q.sql
    |> io.debug()
    |> run.run(db, users_posts_decoder.continuation) // this decoder is generated for us!
    |> io.debug
```

To export the query, just run
```gleam
|> q.export
```
And then you can, in the same pipeline, use it as a `cake/select` query! Awesome!

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

### Record-to-dict

These functions allow you to convert records to dictionaries. Useful for changesets!


## Changesets! (WIP)

Taking after Ecto, ormlette supports Changesets. Changesets allow you to validate and trnsform data before you insert it into your database

> The changesets lib is currently working, but not with the nicest API, so I would not currently use them. THIS MESSAGE WILL BE UPDATED WHEN I DISAGREE WITH IT

### Usage
To use a changeset, you can define custom error types to use, which allows it to feel more "you". For example:
```gleam
pub type CustomError {
  NameEmptyError(String)
  InvalidEmailError(String)
  AgeBelowMinimum(String)
}
```

Then, you define validators. Validators work like this:

```gleam
import ormlette/changesets/changesets
import ormlette_validate/string
import ormlette_validate/int
import ormlette_validate/option

pub fn validate_user(
  u: decode.Users,
) -> changesets.Changeset(decode.Useers, CustomError) {
  changesets.new(u)
  |> changesets.validate_field(
    u.name,
    optional.optional(
      string.is_not_empty(InvalidEmailError("Email format is invalid.")),
    ),
  )
  |> changesets.validate_field(
    u.id,
    optional.optional(int.min(1, InvalidEmailError("Email format is invalid."))),
  )
}
```

Hopefully this is clear, I will update later with further instructions on the validation stuff.

Okay, then finally you can run them by inserting a type. I will add examples for this later. IF SOMEONE WANTS TO HELP WITH DOCS THAT WOULD BE SUPER APPRECIATED
