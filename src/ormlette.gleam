// import cake
// import cake/dialect/postgres_dialect
// import cake/select
// import cake/where
// import gleam/io
// import gleam/option
// import ormlet/ir/ir
// import ormlet/ir/sql
// import ormlet/query/query
// import ormlet/schema/create as c
// import ormlet/templates/tables
// import ormlet/templates/utils/to_string
// import output.{orders, users}

// pub fn main() {
//   let user_table =
//     c.define_table("users", [
//       c.int_column("id") |> c.primary |> c.unique,
//       c.text_column("name"),
//     ])

//   let orders_table =
//     c.define_table("orders", [
//       c.int_column("order_id") |> c.primary,
//       c.int_column("user_id")
//         |> c.foreign_key(
//           user_table,
//           "id",
//           option.Some("CASCADE"),
//           option.Some("CASCADE"),
//         ),
//     ])

//   let users_sql = ir.to_ir(user_table) |> sql.to_sql
//   io.debug(users_sql)
//   let orders_sql = ir.to_ir(orders_table) |> sql.to_sql
//   io.debug(orders_sql)

//   let order = orders()
//   let user = users()

//   query.from_table(orders_table)
//   |> query.inner_join(user_table)
//   |> query.select([order.order_id, user.name])
//   |> query.equals(order.order_id, 1)
//   |> query.order_by(user.name, select.Asc)
//   |> query.export
//   |> select.where(where.gt(where.col(order.order_id), where.int(1)))
//   |> select.to_query
//   |> postgres_dialect.read_query_to_prepared_statement
//   |> cake.get_sql
//   |> io.debug
//   // io.debug(query.sql(query))

//   tables.render([user_table, orders_table])
//   |> to_string.to_file("./src/output.gleam", to_string.Write)
// }

import gleam/io
import ormlette/cli/generate
import shellout
import simplifile

pub fn main() {
  generate.create_generate_file()
  work()
}

pub fn work() {
  let assert Ok(cwd) = simplifile.current_directory()
  case
    shellout.command(
      "gleam",
      ["run", "-m", "eggs/generate"],
      in: cwd <> "/",
      opt: [],
    )
  {
    Ok(res) -> {
      io.println("Successfully generated types and decoders.")
      Ok(Nil)
    }
    Error(e) -> {
      io.debug("Error generating types and decoders")
      Error(Nil)
    }
  }
}
