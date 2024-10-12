import cake/insert
import gleam/dynamic
import gleam/pgo
import gleam/result

pub fn wrap_pgo(value: dynamic.Dynamic) {
  case dynamic.classify(value) {
    "String" -> pgo.text(result.unwrap(dynamic.string(value), ""))
    "Int" -> pgo.int(result.unwrap(dynamic.int(value), 1))
    "Bool" -> pgo.bool(result.unwrap(dynamic.bool(value), True))
    "Float" -> pgo.float(result.unwrap(dynamic.float(value), 0.0))
    _ -> panic
  }
}

pub fn wrap_cake(value: dynamic.Dynamic) {
  case dynamic.classify(value) {
    "String" -> insert.string(result.unwrap(dynamic.string(value), ""))
    "Int" -> insert.int(result.unwrap(dynamic.int(value), 1))
    "Bool" -> insert.bool(result.unwrap(dynamic.bool(value), True))
    "Float" -> insert.float(result.unwrap(dynamic.float(value), 0.0))
    _ -> panic
  }
}
