import gleam/dynamic
import gleam/int
import gleam/list
import gleam/option
import gleam/string
import ormlette/ir/ir
import ormlette/schema/create as c

pub fn helper(column: ir.ColumnIR) -> String {
  case column.type_ {
    c.Int -> "int"
    c.Bool -> "bool"
    c.String -> "text"
    c.ForeignKey -> {
      let fk_constraint =
        list.filter(column.constraints, fn(con) {
          case con {
            ir.ForeignKey(_, _, _, _) -> True
            _ -> False
          }
        })
      case list.first(fk_constraint) {
        Ok(ir.ForeignKey(ref_table, ref_column, _, _)) -> {
          let col =
            list.find(ref_table.columns, fn(col) { col.name == ref_column })
          case col {
            Ok(found_col) -> helper(found_col)
            _ -> panic
          }
        }
        Error(_) -> panic
        _ -> panic
      }
    }
    c.Serial -> "SERIAL"
  }
}

pub fn to_sql(table_ir: ir.TableIR) -> String {
  let columns_sql =
    table_ir.columns |> list.map(column_to_sql) |> string.join(", ")
  "CREATE TABLE " <> table_ir.name <> " (" <> columns_sql <> ");"
}

fn column_to_sql(column_ir: ir.ColumnIR) -> String {
  let constraints_sql =
    column_ir.constraints |> list.map(constraint_to_sql) |> string.join(" ")
  let default_sql = case column_ir.default {
    option.None -> ""
    option.Some(value) -> "DEFAULT " <> dynamic_to_sql(value)
  }
  column_ir.name
  <> " "
  <> helper(column_ir)
  <> " "
  <> constraints_sql
  <> " "
  <> default_sql
}

fn constraint_to_sql(constraint: ir.ColumnConstraint) -> String {
  case constraint {
    ir.PrimaryKey -> "PRIMARY KEY"
    ir.Nullable -> "NULL"
    ir.Unique -> "UNIQUE"
    ir.ForeignKey(ref_table, ref_column, on_delete, on_update) ->
      "REFERENCES "
      <> ref_table.name
      <> "("
      <> ref_column
      <> ") "
      <> case on_delete {
        option.Some(action) -> "ON DELETE " <> action <> " "
        option.None -> ""
      }
      <> case on_update {
        option.Some(action) -> "ON UPDATE " <> action
        option.None -> ""
      }
  }
}

fn dynamic_to_sql(value: dynamic.Dynamic) -> String {
  case dynamic.string(value) {
    Ok(str_val) -> "'" <> str_val <> "'"
    Error(_) ->
      case dynamic.int(value) {
        Ok(int_val) -> int.to_string(int_val)
        _ -> panic
      }
  }
}

pub fn to_sql_drop(table_ir: ir.TableIR) -> String {
  "DROP TABLE " <> table_ir.name <> ";"
}

pub fn to_sql_drop_column(table_name: String, column_name: String) -> String {
  "ALTER TABLE " <> table_name <> " DROP COLUMN " <> column_name <> ";"
}
