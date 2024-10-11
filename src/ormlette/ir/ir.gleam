//// This is an `intermediate representation` (IR) for the schema definition to convert it to a SQL `CREATE TABLE` statement.
//// The IR is a data structure that represents the schema in a way that is easy to convert to SQL.

import gleam/dynamic
import gleam/list
import gleam/option.{type Option, None, Some}
import ormlette/schema/create

/// The IR type for a table
/// It contains the table name and a list of columns (Basically the same as the `create.Table` type)
pub type TableIR {
  TableIR(name: String, columns: List(ColumnIR))
}

/// This is the IR type for a column.
pub type ColumnIR {
  ColumnIR(
    name: String,
    type_: create.ColumnType,
    constraints: List(ColumnConstraint),
    default: Option(dynamic.Dynamic),
  )
}

/// Ir type for a column constraint, such as a `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, etc.
pub type ColumnConstraint {
  PrimaryKey
  Nullable
  Unique
  ForeignKey(
    references_table: TableIR,
    references_column: String,
    on_delete: Option(String),
    on_update: Option(String),
  )
}

/// This function converts a `create.Table` to a `TableIR`
pub fn to_ir(table: create.Table) -> TableIR {
  TableIR(name: table.name, columns: list.map(table.columns, column_to_ir))
}

/// This function converts a `create.Column` to a `ColumnIR`
fn column_to_ir(column: create.Column) -> ColumnIR {
  let constraints =
    list.concat([
      case column.is_primary {
        True -> [PrimaryKey]
        False -> []
      },
      case column.is_nullable {
        True -> [Nullable]
        False -> []
      },
      case column.is_unique {
        True -> [Unique]
        False -> []
      },
      case column.references {
        Some(ref) -> [
          ForeignKey(
            references_table: TableIR(
              ref.table.name,
              list.map(ref.table.columns, fn(c) { column_to_ir(c) }),
            ),
            references_column: ref.column,
            on_delete: ref.on_delete,
            on_update: ref.on_update,
          ),
        ]
        None -> []
      },
    ])

  ColumnIR(
    name: column.name,
    type_: column.type_,
    constraints: constraints,
    default: column.default,
  )
}
