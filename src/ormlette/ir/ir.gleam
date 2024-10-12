import gleam/dynamic
import gleam/list
import gleam/option.{type Option, None, Some}
import ormlette/schema/create as c

pub type TableIR {
  TableIR(name: String, columns: List(ColumnIR))
}

pub type ColumnIR {
  ColumnIR(
    name: String,
    type_: c.ColumnType,
    constraints: List(ColumnConstraint),
    default: Option(dynamic.Dynamic),
  )
}

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

pub fn to_ir(table: c.Table) -> TableIR {
  TableIR(name: table.name, columns: list.map(table.columns, column_to_ir))
}

fn column_to_ir(column: c.Column) -> ColumnIR {
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

pub fn inverse_ir(table_ir: TableIR) -> String {
  to_sql_drop(table_ir)
}

pub fn to_sql_drop(table_ir: TableIR) -> String {
  "DROP TABLE " <> table_ir.name <> ";"
}
