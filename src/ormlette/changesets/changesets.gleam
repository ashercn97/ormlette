import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

// Define the Error and Changeset types.
pub type Error {
  FieldError(field: String, message: String)
}

// The Changeset type wraps a dictionary of data, along with validation errors and validity status.
pub type Changeset {
  Changeset(data: dict.Dict(String, Dynamic), errors: List(Error), valid: Bool)
}

// Initialize a changeset with a dictionary.
pub fn new(data: dict.Dict(String, Dynamic)) -> Changeset {
  Changeset(data, [], True)
}

// Validator to ensure a field is present (i.e., not None).
pub fn validate_present(changeset: Changeset, fields: List(String)) -> Changeset {
  let Changeset(data, errors, valid) = changeset

  list.fold(fields, changeset, fn(changeset, field) {
    case dict.get(data, field) {
      Error(_) ->
        Changeset(
          data,
          list.append([FieldError(field, "must be present")], errors),
          False,
        )
      Ok(_) -> changeset
    }
  })
}

// Validator to ensure a field value has a minimum integer value.
pub fn validate_min(changeset: Changeset, field: String, min: Int) -> Changeset {
  let Changeset(data, errors, valid) = changeset
  let is_smaller =
    result.unwrap(
      dynamic.int(result.unwrap(dict.get(data, field), dynamic.from(0))),
      0,
    )
    < min
  case dict.get(data, field) {
    Ok(value) if is_smaller ->
      Changeset(
        data,
        list.append(
          [FieldError(field, "must be at least " <> int.to_string(min))],
          errors,
        ),
        False,
      )
    _ -> changeset
  }
}

// Validator to ensure a field string length falls within a specified range.
pub fn validate_length(
  changeset: Changeset,
  field: String,
  min: Int,
  max: Int,
) -> Changeset {
  let Changeset(data, errors, valid) = changeset

  case dict.get(data, field) {
    Ok(value) -> {
      let v_string_result = dynamic.optional(dynamic.string)(value)
      case v_string_result {
        Ok(v_string) -> {
          let v_length = option.map(v_string, string.length)
          case v_length {
            option.Some(len) if len < min || len > max ->
              Changeset(
                data,
                list.append(
                  [
                    FieldError(
                      field,
                      "length must be between "
                        <> int.to_string(min)
                        <> " and "
                        <> int.to_string(max),
                    ),
                  ],
                  errors,
                ),
                False,
              )

            _ -> changeset
          }
        }
        Error(_) -> changeset
      }
    }
    Error(_) -> changeset
  }
}

// Function to check if a changeset is valid.
pub fn is_valid(changeset: Changeset) -> Bool {
  changeset.valid
}

// Function to retrieve errors from a changeset.
pub fn errors(changeset: Changeset) -> List(Error) {
  changeset.errors
}
