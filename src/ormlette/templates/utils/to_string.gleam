import filepath
import ormlette/schema/create as c
import simplifile

pub fn coltype(col: c.Column) {
  case col.type_ {
    c.Int -> "Int"
    c.Bool -> "Bool"
    c.ForeignKey -> "Int"
    // TODO make work better
    c.String -> "String"
  }
}

pub fn decode_type(col: c.Column) {
  case col.type_ {
    c.Int -> "decode.int"
    c.Bool -> "decode.bool"
    c.ForeignKey -> "decode.int"
    c.String -> "decode.string"
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
