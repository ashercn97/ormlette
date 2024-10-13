import gleam/dict
import gleam/dynamic
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string

import ormlette_validate/valid.{FieldValidator, Validator, validate_dict}

// Define the Error and Changeset types.
pub type Error {
  FieldError(field: String, message: String)
}

// The Changeset type wraps a dictionary of data, along with validation errors and validity status.
pub type Changeset {
  Changeset(
    table: String,
    data: dict.Dict(String, dynamic.Dynamic),
    errors: List(Error),
    valid: Bool,
  )
}

// Initialize a changeset with a dictionary.
pub fn new(table: String, data: dict.Dict(String, dynamic.Dynamic)) -> Changeset {
  Changeset(table, data, [], True)
}

// Validator for minimum integer value.
pub fn validate_min(changeset: Changeset, field: String, min: Int) -> Changeset {
  validate_field(changeset, field, valid.min(min))
}

// Validator for maximum integer value.
pub fn validate_max(changeset: Changeset, field: String, max: Int) -> Changeset {
  validate_field(changeset, field, valid.max(max))
}

// Validator for checking non-empty values.
pub fn validate_present(changeset: Changeset, fields: List(String)) -> Changeset {
  let field_validators =
    list.map(fields, fn(field) { FieldValidator(field, valid.is_not_empty()) })
  validate_fields(changeset, field_validators)
}

// Validator for minimum string length.
pub fn validate_min_length(
  changeset: Changeset,
  field: String,
  min_length: Int,
) -> Changeset {
  validate_field(changeset, field, valid.has_min_length(min_length))
}

// Validator for positive integer values.
pub fn validate_positive(changeset: Changeset, field: String) -> Changeset {
  validate_field(changeset, field, valid.is_positive())
}

// Validator for negative integer values.
pub fn validate_negative(changeset: Changeset, field: String) -> Changeset {
  validate_field(changeset, field, valid.is_negative())
}

// Validator for checking number format.
pub fn validate_number(changeset: Changeset, field: String) -> Changeset {
  validate_field(changeset, field, valid.is_number())
}

// Validator for boolean values.
pub fn validate_boolean(changeset: Changeset, field: String) -> Changeset {
  validate_field(changeset, field, valid.is_boolean())
}

// Validator for string pattern matching.
pub fn validate_regex(
  changeset: Changeset,
  field: String,
  pattern: String,
) -> Changeset {
  validate_field(changeset, field, valid.matches_regex(pattern))
}

// Validator for checking if the value is in a specified list.
pub fn validate_in_list(
  changeset: Changeset,
  field: String,
  allowed_values: List(dynamic.Dynamic),
) -> Changeset {
  validate_field(changeset, field, valid.is_in_list(allowed_values))
}

// Generalized function to apply a field validator.
fn validate_field(
  changeset: Changeset,
  field: String,
  validator: valid.Validator(dynamic.Dynamic),
) -> Changeset {
  let Changeset(table, data, errors, valid) = changeset
  let field_validator = FieldValidator(field, validator)

  case validate_dict(data, [field_validator]) {
    Ok(_) -> changeset
    Error(new_errors) ->
      Changeset(
        table,
        data,
        list.append(errors, format_errors([field], new_errors)),
        False,
      )
  }
}

// Helper function to apply multiple validators.
fn validate_fields(
  changeset: Changeset,
  field_validators: List(valid.FieldValidator),
) -> Changeset {
  let Changeset(table, data, errors, valid) = changeset

  case validate_dict(data, field_validators) {
    Ok(_) -> changeset
    Error(new_errors) ->
      Changeset(
        table,
        data,
        list.append(
          errors,
          format_errors(
            list.map(field_validators, fn(fv) {
              case fv {
                valid.FieldValidator(field, _) -> field
              }
            }),
            new_errors,
          ),
        ),
        False,
      )
  }
}

// Check if the changeset is valid
pub fn is_valid(changeset: Changeset) -> Bool {
  changeset.valid
}

// Retrieve errors from the changeset
pub fn errors(changeset: Changeset) -> List(Error) {
  changeset.errors
}

// Format errors for the changeset
fn format_errors(fields: List(String), messages: List(String)) -> List(Error) {
  list.map(messages, fn(msg) {
    FieldError(result.unwrap(list.first(fields), ""), msg)
  })
}
