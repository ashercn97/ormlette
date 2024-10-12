import cake
import cake/dialect/postgres_dialect
import cake/insert
import gleam/dict
import gleam/dynamic
import gleam/list
import gleam/pgo
import ormlette/changesets/changesets
import ormlette/query/run
import ormlette/repo/utils

pub fn insert(changeset: changesets.Changeset, db: pgo.Connection) {
  let keys = dict.keys(changeset.data)
  let values = dict.values(changeset.data)

  let prepstat =
    [list.map(values, fn(v) { utils.wrap_cake(v) }) |> insert.row]
    |> insert.from_values(table_name: changeset.table, columns: keys)
    |> insert.to_query
    |> postgres_dialect.write_query_to_prepared_statement

  let results =
    #(cake.get_sql(prepstat), cake.get_params(prepstat))
    |> run.run(db, dynamic.dynamic)

  case results {
    Ok(_) -> Ok("WORKED")
    Error(_) -> Error("Didnt work :(")
  }
}
