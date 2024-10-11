////  These functions are helpers for the query building. Are NOT used much, might remove later

import cake
import cake/dialect/postgres_dialect
import cake/select

/// This turns a select value to a prepared statement. Literally just calling cake functions.
pub fn select_to_sql(select: select.Select) {
  let prep =
    select
    |> select.to_query
    |> postgres_dialect.read_query_to_prepared_statement

  #(cake.get_sql(prep), cake.get_params(prep))
}
