import cake
import cake/dialect/postgres_dialect
import cake/insert
import gleam/dict
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/option
import gleam/pgo
import gleam/result
import ormlette/changesets/changesets
import ormlette/query/run
import ormlette/repo/utils

// pub fn insert(
//   changeset: changesets.Changeset(_, _),
//   to_dict: fn(_) -> dict.Dict(String, dynamic.Dynamic),
//   table: String,
//   db: pgo.Connection,
// ) {
//   let d = case changeset.data {
//     Ok(v) -> to_dict(v)
//     Error(_) -> panic
//   }

//   let keys = dict.keys(d)
//   let values = dict.values(d)

//   let prepstat =
//     [list.map(values, fn(v) { utils.wrap_cake(v) }) |> insert.row]
//     |> insert.from_values(table_name: table, columns: keys)
//     |> insert.to_query
//     |> postgres_dialect.write_query_to_prepared_statement

//   io.debug(prepstat)

//   let results =
//     #(cake.get_sql(prepstat), cake.get_params(prepstat))
//     |> run.run(db, dynamic.dynamic)
//   io.debug(results)
//   case results {
//     Ok(_) -> Ok("WORKED")
//     Error(_) -> Error("Didn't work :(")
//   }
// }

pub fn insert(
  changeset: changesets.Changeset(_, _),
  to_dict: fn(_) -> dict.Dict(String, dynamic.Dynamic),
  table: String,
  db: pgo.Connection,
) {
  let d = case changeset.data {
    Ok(v) -> to_dict(v)
    Error(_) -> panic
  }

  // Filter out None values from keys and values
  let filtered_entries =
    dict.to_list(d)
    |> list.filter_map(fn(l) {
      let #(key, value) = l
      case utils.wrap_cake(value) {
        option.Some(val) -> Ok(#(key, val))
        // option.None -> Error(_)
        option.None -> Error("GIRAFFE")
      }
    })

  let keys = list.map(filtered_entries, fn(entry) { entry.0 })
  let values = list.map(filtered_entries, fn(entry) { entry.1 })

  let prepstat =
    [insert.row(values)]
    |> insert.from_values(table_name: table, columns: keys)
    |> insert.to_query
    |> postgres_dialect.write_query_to_prepared_statement

  io.debug(prepstat)

  let results =
    #(cake.get_sql(prepstat), cake.get_params(prepstat))
    |> run.run(db, dynamic.dynamic)
  io.debug(results)
  case results {
    Ok(_) -> Ok("WORKED")
    Error(_) -> Error("Didn't work :(")
  }
}
