import cake/insert
import gleam/dynamic
import gleam/io
import gleam/option
import gleam/pgo
import gleam/result
import gleam/string
import gledo

pub fn wrap_pgo(value: dynamic.Dynamic) {
  case dynamic.classify(value) {
    "String" -> pgo.text(result.unwrap(dynamic.string(value), ""))
    "Int" -> pgo.int(result.unwrap(dynamic.int(value), 1))
    "Bool" -> pgo.bool(result.unwrap(dynamic.bool(value), True))
    "Float" -> pgo.float(result.unwrap(dynamic.float(value), 0.0))
    "Optional(" <> v -> {
      case v {
        "Int)" -> pgo.int(result.unwrap(dynamic.int(value), 1))
        _ -> {
          io.debug(v)
          panic
        }
      }
    }
    _ -> panic
  }
}

// pub fn wrap_cake(value: dynamic.Dynamic) {
//   case dynamic.classify(value) {
//     "String" -> insert.string(result.unwrap(dynamic.string(value), ""))
//     "Int" -> insert.int(result.unwrap(dynamic.int(value), 1))
//     "Bool" -> insert.bool(result.unwrap(dynamic.bool(value), True))
//     "Float" -> insert.float(result.unwrap(dynamic.float(value), 0.0))
//     _ -> {
//       case gledo.decode_option(value) {
//         Ok(option.Some(v2)) -> wrap_cake(dynamic.from(v2))
//         Ok(option.None) -> insert.null()
//         Error(_) -> panic
//       }
//     }
//   }
// }

pub fn wrap_cake(value: dynamic.Dynamic) -> option.Option(_) {
  case dynamic.classify(value) {
    "String" ->
      option.Some(insert.string(result.unwrap(dynamic.string(value), "")))
    "Int" -> option.Some(insert.int(result.unwrap(dynamic.int(value), 1)))
    "Bool" -> option.Some(insert.bool(result.unwrap(dynamic.bool(value), True)))
    "Float" ->
      option.Some(insert.float(result.unwrap(dynamic.float(value), 0.0)))
    _ -> {
      case gledo.decode_option(value) {
        Ok(option.Some(v2)) -> wrap_cake(dynamic.from(v2))
        Ok(option.None) -> option.None
        // Skip null values
        Error(_) -> panic
      }
    }
  }
}
