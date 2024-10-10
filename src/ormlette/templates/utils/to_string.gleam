import filepath
import ormlette/schema/create as c
import simplifile
import gleam/list
import gleam/option

pub fn coltype(column: c.Column) {
  case column.type_ {
    c.Int -> "Int"
    c.Bool -> "Bool"
    c.String -> "String"
    c.ForeignKey -> {
      let hi = case column.references {
        option.Some(ref) -> {
          let col =
            list.find(ref.table.columns, fn(col) {
              col.name == ref.column
            })
          case col {
            Ok(found_col) -> coltype(found_col)
            Error(_) -> panic
          }
        }
        option.None -> panic
      }
    }
    c.Serial -> "Int"
  }
}


pub fn decode_type(column: c.Column) {
  case column.type_ {
    c.Int -> "decode.int"
    c.Bool -> "decode.bool"
    c.String -> "decode.string"
    c.ForeignKey -> {
      let hi = case column.references {
        option.Some(ref) -> {
          let col =
            list.find(ref.table.columns, fn(col) {
              col.name == ref.column
            })
          case col {
            Ok(found_col) -> decode_type(found_col)
            Error(_) -> panic
          }
        }
        option.None -> panic
      }
    }
    c.Serial -> "decode.int"
  }
}


pub type Style {
  Append
  Write
}

pub fn to_file(info: String, path path: String, style style: Style) {
  simplifile.create_directory(filepath.directory_name(path))
  case style {
    Append -> {
      let assert Ok(_) = simplifile.append(path, contents: info)
    }
    Write -> {
      let assert Ok(_) = simplifile.write(path, contents: info)
    }
  }
}
