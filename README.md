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

pub fn users2_table() {
  c.define_table("users", [
    c.serial("id") |> c.primary,
    c.text("name") |> c.nullable,
  ])
}
```

To generate everything you need to work with databases, run `gleam run -m ormlette` and look in the `src/eggs` directory.
