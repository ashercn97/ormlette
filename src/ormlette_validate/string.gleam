import gleam/regexp
import gleam/string
import non_empty_list
import ormlette_validate/valid

/// Validate that a string is not empty, with a custom error type
pub fn is_not_empty(error: e) -> valid.Validator(String, String, e) {
  fn(value: String) {
    case string.is_empty(value) {
      True -> Error(non_empty_list.new(error, []))
      False -> Ok(value)
    }
  }
}

/// Validate that a string matches an email pattern, with a custom error type
pub fn is_email(error: e) -> valid.Validator(String, String, e) {
  fn(value: String) {
    let pattern = "^([\\w\\d]+)(\\.[\\w\\d]+)*(\\+[\\w\\d]+)?@[\\w\\d\\.]+$"
    case regexp.from_string(pattern) {
      Ok(re) -> {
        case regexp.check(with: re, content: value) {
          True -> Ok(value)
          False -> Error(non_empty_list.new(error, []))
        }
      }
      Error(_) -> Error(non_empty_list.new(error, []))
    }
  }
}
