import gleam/dynamic
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}

// DbType for handling SQL column types
pub type DbType {
  Integer
  Text
  Real
  Blob
}

// Extend ColumnType to support foreign keys
pub type ColumnType {
  Int
  String
  Bool
  ForeignKey
  Serial
}

// Column type with dynamic type to allow mixed types in a list
pub type Column {
  Column(
    name: String,
    type_: ColumnType,
    is_primary: Bool,
    is_nullable: Bool,
    is_unique: Bool,
    default: Option(dynamic.Dynamic),
    references: Option(Reference),
    // New field for foreign key references
  )
}

// Reference type for foreign keys with options for cascading behavior
pub type Reference {
  Reference(
    table: Table,
    column: String,
    on_delete: Option(String),
    on_update: Option(String),
  )
}

// Helper functions to create Columns with defaults and attribute functions

pub fn int(name: String) -> Column {
  Column(
    name: name,
    type_: Int,
    is_primary: False,
    is_nullable: False,
    is_unique: False,
    default: None,
    references: None,
  )
}

pub fn text(name: String) -> Column {
  Column(
    name: name,
    type_: String,
    is_primary: False,
    is_nullable: False,
    is_unique: False,
    default: None,
    references: None,
  )
}

pub fn serial(name: String) -> Column {
  Column(
    name: name,
    type_: Serial,
    is_primary: True,
    is_nullable: False,
    is_unique: True,
    default: None,
    references: None,
  )
}

// New helper function for foreign key column creation
pub fn foreign_key(
  col: Column,
  references_table: Table,
  references_column: String,
  // on_delete: Option(String),
  // on_update: Option(String),
) -> Column {
  // Validate that the referenced column exists in the target table
  let column_exists =
    list.contains(
      list.map(references_table.columns, fn(column) { column.name }),
      references_column,
    )

  case column_exists {
    True ->
      Column(
        name: col.name,
        type_: ForeignKey,
        is_primary: col.is_primary,
        is_nullable: col.is_nullable,
        is_unique: col.is_unique,
        default: col.default,
        references: Some(Reference(
          table: references_table,
          column: references_column,
          on_delete: option.None,
          on_update: option.None,
        )),
      )
    False -> panic
  }
}

// Fluent API for adding column attributes: primary, nullable, unique, and default

pub fn primary(col: Column) -> Column {
  Column(
    name: col.name,
    type_: col.type_,
    is_primary: True,
    is_nullable: col.is_nullable,
    is_unique: col.is_unique,
    default: col.default,
    references: col.references,
  )
}

pub fn nullable(col: Column) -> Column {
  Column(
    name: col.name,
    type_: col.type_,
    is_primary: col.is_primary,
    is_nullable: True,
    is_unique: col.is_unique,
    default: col.default,
    references: col.references,
  )
}

pub fn unique(col: Column) -> Column {
  Column(
    name: col.name,
    type_: col.type_,
    is_primary: col.is_primary,
    is_nullable: col.is_nullable,
    is_unique: True,
    default: col.default,
    references: col.references,
  )
}

pub fn default(col: Column, value: a) -> Column {
  Column(
    name: col.name,
    type_: col.type_,
    is_primary: col.is_primary,
    is_nullable: col.is_nullable,
    is_unique: col.is_unique,
    default: Some(dynamic.from(value)),
    references: col.references,
  )
}

// Table type with a name and a list of columns
pub type Table {
  Table(name: String, columns: List(Column))
}

// Define table helper function
pub fn define_table(name: String, columns: List(Column)) -> Table {
  Table(name, columns)
}

// Helper function to format column SQL with foreign key support
pub fn format_column_sql(column: Column) -> String {
  let primary_sql = case column.is_primary {
    True -> "PRIMARY KEY"
    False -> ""
  }
  let nullable_sql = case column.is_nullable {
    True -> "NULL"
    False -> "NOT NULL"
  }
  let unique_sql = case column.is_unique {
    True -> "UNIQUE"
    False -> ""
  }
  let default_sql = case column.default {
    None -> ""
    Some(val) ->
      "DEFAULT "
      <> {
        case dynamic.string(val) {
          Ok(value) -> value
          Error(_) -> panic
        }
      }
  }

  let foreign_key_sql = case column.references {
    Some(ref) ->
      "REFERENCES "
      <> ref.table.name
      <> "("
      <> ref.column
      <> ") "
      <> case ref.on_delete {
        Some(action) -> "ON DELETE " <> action <> " "
        None -> ""
      }
      <> case ref.on_update {
        Some(action) -> "ON UPDATE " <> action
        None -> ""
      }
    None -> ""
  }

  column.name
  <> " "
  <> dbtype_to_string(column.type_)
  <> " "
  <> primary_sql
  <> " "
  <> nullable_sql
  <> " "
  <> unique_sql
  <> " "
  <> default_sql
  <> " "
  <> foreign_key_sql
}

pub fn dbtype_to_string(dbtype: ColumnType) -> String {
  case dbtype {
    Int -> "int"
    String -> "text"
    Bool -> "bool"
    ForeignKey -> "int"
    Serial -> "int"
  }
}
