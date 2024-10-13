import gleam/dict
import gleam/dynamic
import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/string

pub type Validator(input) {
  Validator(fn(input) -> Result(input, List(String)))
}

pub type FieldValidator {
  FieldValidator(String, Validator(dynamic.Dynamic))
}

pub fn validate(
  input: input,
  validators: List(Validator(input)),
) -> Result(input, List(String)) {
  list.fold(validators, Ok(input), fn(acc, v) {
    case v {
      Validator(f) -> {
        case acc {
          Ok(val) -> f(val)
          Error(errs) ->
            case f(input) {
              Ok(_) -> acc
              Error(new_errs) -> Error(list.append(errs, new_errs))
            }
        }
      }
    }
  })
}

pub fn validate_dict(
  input: dict.Dict(String, dynamic.Dynamic),
  field_validators: List(FieldValidator),
) -> Result(dict.Dict(String, dynamic.Dynamic), List(String)) {
  list.fold(field_validators, Ok(input), fn(acc, field_validator) {
    case field_validator {
      FieldValidator(field, Validator(f)) -> {
        case dict.get(input, field) {
          Ok(value) -> {
            case f(value) {
              Ok(_) -> acc
              Error(new_errs) -> {
                case acc {
                  Ok(_) -> Error(new_errs)
                  Error(errs) -> Error(list.append(errs, new_errs))
                }
              }
            }
          }
          Error(_) -> acc
        }
      }
    }
  })
}

pub fn is_not_empty() -> Validator(dynamic.Dynamic) {
  Validator(fn(input) {
    case dynamic.string(input) {
      Ok(value) -> {
        case value == "" {
          True -> Error(["Value cannot be empty"])
          False -> Ok(input)
        }
      }
      Error(_) -> Error(["Value is not a string"])
    }
  })
}

pub fn has_min_length(min_length: Int) -> Validator(dynamic.Dynamic) {
  Validator(fn(input) {
    case dynamic.string(input) {
      Ok(value) -> {
        case string.length(value) < min_length {
          True ->
            Error([
              "Value must have at least "
              <> int.to_string(min_length)
              <> " characters",
            ])
          False -> Ok(input)
        }
      }
      Error(_) -> Error(["Value is not a string"])
    }
  })
}

pub fn is_number() -> Validator(dynamic.Dynamic) {
  Validator(fn(input) {
    case dynamic.string(input) {
      Ok(value) -> {
        case int.parse(value) {
          Ok(_) -> Ok(input)
          Error(_) -> Error(["Value must be a number"])
        }
      }
      Error(_) -> {
        case dynamic.int(input) {
          Ok(_) -> Ok(input)
          Error(_) -> Error(["Value is not a number!"])
        }
      }
    }
  })
}

pub fn min(num: Int) -> Validator(dynamic.Dynamic) {
  Validator(fn(input: dynamic.Dynamic) {
    let value_ok = dynamic.int(input)
    case value_ok {
      Ok(value) -> {
        case value >= num {
          True -> Ok(input)
          False ->
            Error([
              "Value must be greater than or equal to " <> int.to_string(num),
            ])
        }
      }
      Error(_) -> Error(["Not an int!"])
    }
  })
}

pub fn max(num: Int) -> Validator(dynamic.Dynamic) {
  Validator(fn(input: dynamic.Dynamic) {
    let value_ok = dynamic.int(input)
    case value_ok {
      Ok(value) -> {
        case value <= num {
          True -> Ok(input)
          False ->
            Error(["Value must be less than or equal to " <> int.to_string(num)])
        }
      }
      Error(_) -> Error(["Not an int!"])
    }
  })
}

pub fn is_boolean() -> Validator(dynamic.Dynamic) {
  Validator(fn(input) {
    case dynamic.bool(input) {
      Ok(_) -> Ok(input)
      Error(_) -> Error(["Value must be a boolean (true or false)"])
    }
  })
}

pub fn matches_regex(pattern: String) -> Validator(dynamic.Dynamic) {
  Validator(fn(input) {
    case dynamic.string(input) {
      Ok(value) -> {
        let assert Ok(regex_pattern) = regex.from_string(pattern)
        case regex.check(regex_pattern, value) {
          True -> Ok(input)
          False ->
            Error(["Value does not match the required pattern: " <> pattern])
        }
      }
      Error(_) -> Error(["Value is not a string"])
    }
  })
}

pub fn is_in_list(
  allowed_values: List(dynamic.Dynamic),
) -> Validator(dynamic.Dynamic) {
  Validator(fn(input) {
    case list.contains(allowed_values, input) {
      True -> Ok(input)
      False ->
        Error([
          "Value must be one of: "
          <> string.join(
            list.map(allowed_values, fn(a) {
              case dynamic.string(a) {
                Ok(v) -> v
                Error(_) -> ""
              }
            }),
            ",",
          ),
        ])
    }
  })
}

pub fn is_positive() -> Validator(dynamic.Dynamic) {
  Validator(fn(input) {
    case dynamic.int(input) {
      Ok(value) -> {
        case value > 0 {
          True -> Ok(input)
          False -> Error(["Value must be positive"])
        }
      }
      Error(_) -> Error(["Value is not a number"])
    }
  })
}

pub fn is_negative() -> Validator(dynamic.Dynamic) {
  Validator(fn(input) {
    case dynamic.int(input) {
      Ok(value) -> {
        case value < 0 {
          True -> Ok(input)
          False -> Error(["Value must be positive"])
        }
      }
      Error(_) -> Error(["Value is not a number"])
    }
  })
}
// // Example usage
// pub fn main() {
//   let input =
//     dict.from_list([#("name", dynamic.from("John")), #("age", dynamic.from(30))])
//   let validators = [
//     FieldValidator("name", is_not_empty()),
//     FieldValidator("age", is_number()),
//     FieldValidator("age", min(10)),
//     FieldValidator("age", max(20)),
//   ]
//   validate_dict(input, validators)
//   |> io.debug
// }
