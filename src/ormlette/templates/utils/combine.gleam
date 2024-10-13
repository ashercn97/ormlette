import gleam/list
import gleam/option
import gleam/result
import gleam/string
import ormlette/schema/create as c

pub type ColumnInfo {
  ColumnInfo(name: String, reference_table: String)
}

pub fn combine(table: c.Table) -> List(c.Table) {
  let values = table_has_fk(table)
  list.map(option.unwrap(values, []), fn(refs) {
    combine_tables(
      case refs.references {
        option.Some(r) -> {
          r.table
        }
        option.None -> panic
      },
      table,
    )
  })
}

pub fn combine_tables(t1: c.Table, t2: c.Table) {
  let t1_columns = t1.columns
  let t1_yay =
    list.map(t1_columns, fn(col) {
      c.Column(
        t1.name <> "." <> col.name,
        // Use dot separator for clarity
        col.type_,
        col.is_primary,
        col.is_nullable,
        col.is_unique,
        col.default,
        col.references,
      )
    })
  let t2_columns = t2.columns

  let t2_yay =
    list.map(t2_columns, fn(col) {
      c.Column(
        t2.name <> "." <> col.name,
        // Use dot separator for clarity
        col.type_,
        col.is_primary,
        col.is_nullable,
        col.is_unique,
        col.default,
        col.references,
      )
    })
  c.Table(t1.name <> "_" <> t2.name, list.append(t1_yay, t2_yay))
  // Keep underscore for table name
}

pub fn table_has_fk(table: c.Table) -> option.Option(List(c.Column)) {
  let r =
    list.filter(table.columns, fn(col) {
      case col.type_ {
        c.ForeignKey -> True
        _ -> False
      }
    })
  option.Some(r)
}

pub fn get_column_info(table: c.Table) -> List(ColumnInfo) {
  list.map(table.columns, fn(col) {
    let parts = string.split(col.name, ".")
    let table_name = list.first(parts) |> result.unwrap("")
    let column_name = list.last(parts) |> result.unwrap("")
    ColumnInfo(name: table_name, reference_table: column_name)
  })
}
