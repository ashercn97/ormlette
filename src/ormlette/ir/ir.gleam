import gleam/dynamic
import gleam/list
import gleam/option.{type Option, None, Some}
import ormlette/schema/create

pub type TableIR {
  TableIR(name: String, columns: List(ColumnIR))
}

// Extend ColumnIR to support foreign keys
pub type ColumnIR {
  ColumnIR(
    name: String,
    type_: create.ColumnType,
    constraints: List(ColumnConstraint),
    default: Option(dynamic.Dynamic),
  )
}

// Add ForeignKey constraint to ColumnConstraint
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

// Update the IR conversion function to handle foreign keys
pub fn to_ir(table: create.Table) -> TableIR {
  TableIR(name: table.name, columns: list.map(table.columns, column_to_ir))
}

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
