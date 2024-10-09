import cake
import cake/dialect/postgres_dialect
import cake/join
import cake/select
import cake/where
import gleam/dynamic
import gleam/list
import gleam/option.{None, Some}
import ormlette/schema/create

// Helper function to find a column by name in a table, returning Option instead of Result
fn find_column(
  table: create.Table,
  column_name: String,
) -> option.Option(create.Column) {
  case list.find(table.columns, fn(col) { col.name == column_name }) {
    Ok(v) -> Some(v)
    Error(_) -> None
  }
}

// Helper function to check if a column exists in the schema
fn column_exists(table: create.Table, column_name: String) -> Bool {
  list.any(table.columns, fn(column) { column.name == column_name })
}

// Convert dynamic value to a compatible `WhereValue`
fn to_where_value(value: dynamic.Dynamic) -> where.WhereValue {
  case dynamic.int(value) {
    Ok(value) -> where.int(value)
    Error(_) ->
      case dynamic.string(value) {
        Ok(value) -> where.string(value)
        Error(_) ->
          case dynamic.float(value) {
            Ok(value) -> where.float(value)
            Error(_) ->
              case dynamic.bool(value) {
                Ok(value) ->
                  case value {
                    True -> where.true()
                    False -> where.false()
                  }
                Error(_) -> where.null()
              }
          }
      }
  }
}

// Finds foreign key relationship between source and target tables, if any
fn find_relationship(
  source_table: create.Table,
  target_table: create.Table,
) -> option.Option(#(create.Column, create.Column)) {
  case
    list.find_map(source_table.columns, fn(column) {
      case column.references {
        Some(ref) if ref.table.name == target_table.name ->
          case find_column(target_table, ref.column) {
            Some(target_col) -> Ok(#(column, target_col))
            None -> Error(#())
          }
        _ -> Error(#())
      }
    })
  {
    Ok(v) -> option.Some(v)
    Error(_) -> option.None
  }
}

pub type Query {
  Query(table: create.Table, select: select.Select)
}

// Initialize a new query for a given table
pub fn from_table(table: create.Table) -> Query {
  Query(table, select.from_table(select.new(), table.name))
}

// Generic join function that applies a specific join type based on the relationship
pub fn join(
  query: Query,
  target_table: create.Table,
  join_type: fn(join.JoinTarget, where.Where, String) -> join.Join,
) -> Query {
  let foreign_key = find_relationship(query.table, target_table)

  case foreign_key {
    Some(#(source_col, target_col)) -> {
      let join_clause =
        join_type(
          join.table(target_table.name),
          where.eq(where.col(source_col.name), where.col(target_col.name)),
          target_table.name,
        )
      let joined_query = select.join(query.select, join_clause)
      Query(query.table, joined_query)
    }
    None -> query
    // If no relationship, return original query
  }
}

// Adds an INNER JOIN automatically based on a foreign key
pub fn inner_join(query: Query, target_table: create.Table) -> Query {
  join(query, target_table, join.inner)
}

// Adds a LEFT JOIN automatically based on a foreign key
pub fn left_join(query: Query, target_table: create.Table) -> Query {
  join(query, target_table, join.left)
}

// Add a SELECT clause to the query for specific columns
pub fn select(query: Query, columns: List(String)) -> Query {
  let select_query =
    list.fold(columns, query.select, fn(column, select_query) {
      select.select(column, select.col(select_query))
    })
  Query(query.table, select_query)
}

// Add an EQUALS clause to the query for filtering
pub fn equals(query: Query, column: String, value: a) -> Query {
  let where_clause =
    where.eq(where.col(column), to_where_value(dynamic.from(value)))
  Query(query.table, select.where(query.select, where_clause))
}

// Add a GREATER_THAN clause to the query for filtering
pub fn greater_than(query: Query, column: String, value: a) -> Query {
  let where_clause =
    where.gt(where.col(column), to_where_value(dynamic.from(value)))
  Query(query.table, select.where(query.select, where_clause))
}

// Add a LESS_THAN clause to the query for filtering
pub fn less_than(query: Query, column: String, value: a) -> Query {
  let where_clause =
    where.lt(where.col(column), to_where_value(dynamic.from(value)))
  Query(query.table, select.where(query.select, where_clause))
}

// Add an ORDER BY clause to the query for sorting
pub fn order_by(
  query: Query,
  column: String,
  direction: select.Direction,
) -> Query {
  let ordered_query = select.order_by(query.select, column, direction)
  Query(query.table, ordered_query)
}

// Export the SQL representation of the query
pub fn sql(query: Query) {
  #(
    cake.get_sql(
      postgres_dialect.read_query_to_prepared_statement(select.to_query(
        query.select,
      )),
    ),
    cake.get_params(
      postgres_dialect.read_query_to_prepared_statement(select.to_query(
        query.select,
      )),
    ),
  )
}

pub fn export(query: Query) {
  query.select
}
