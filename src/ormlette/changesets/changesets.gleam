import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/result
import non_empty_list
import ormlette_validate/valid

/// A list of non-empty errors, used for any failed validations
pub type NonEmptyList(a) =
  non_empty_list.NonEmptyList(a)

/// Result type for each validator function
pub type ValidatorResult(output, error) =
  Result(output, NonEmptyList(error))

/// Main Changeset type
/// - `valid`: Is the changeset valid or not
/// - `data`: Holds validated data values ready to be constructed
/// - `errors`: Holds error messages for invalid fields
pub type Changeset(data, error) {
  Changeset(
    valid: Bool,
    data: Result(data, NonEmptyList(error)),
    errors: List(NonEmptyList(error)),
    con: data,
  )
}

/// Creates an empty changeset based on the constructor
pub fn new(data: data) -> Changeset(data, e) {
  Changeset(valid: True, data: Ok(data), errors: [], con: data)
}

/// Adds an error to the changeset, making it invalid
fn add_error(
  error: NonEmptyList(e),
  changeset: Changeset(d, e),
) -> Changeset(d, e) {
  let updated_errors = list.append(changeset.errors, [error])
  Changeset(
    valid: False,
    data: changeset.data,
    errors: updated_errors,
    con: changeset.con,
  )
}

/// Apply a validator to a field and update the changeset based on the result
pub fn validate_field(
  changeset: Changeset(data, error),
  field_value: input,
  validator: valid.Validator(input, output, error),
) -> Changeset(data, error) {
  let constructor = fn(_) { changeset.con }
  case validator(field_value) {
    Ok(valid_value) -> {
      let next_data =
        result.map(changeset.data, fn(data) { constructor(valid_value) })
      Changeset(
        valid: changeset.valid,
        data: next_data,
        errors: changeset.errors,
        con: changeset.con,
      )
    }
    Error(field_errors) -> add_error(field_errors, changeset)
  }
}

/// Checks if the changeset is valid
pub fn is_valid(changeset: Changeset(d, e)) -> Bool {
  changeset.valid
}

/// Attempts to finalize the changeset and get the data if valid
pub fn finalize(changeset: Changeset(d, e)) -> Result(d, NonEmptyList(e)) {
  changeset.data
}
