import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/regex
import gleam/result
import gleam/string
import non_empty_list

pub type NonEmptyList(a) =
  non_empty_list.NonEmptyList(a)

pub type ValidatorResult(output, error) =
  Result(output, NonEmptyList(error))

pub type Validator(input, output, error) =
  fn(input) -> ValidatorResult(output, error)

/// Internal Utility
///
fn curry2(constructor: fn(a, b) -> value) {
  fn(a) { fn(b) { constructor(a, b) } }
}

fn curry3(constructor: fn(a, b, c) -> value) {
  fn(a) { fn(b) { fn(c) { constructor(a, b, c) } } }
}

/// Add errors to result
fn add_errors(
  result: Result(a, NonEmptyList(e)),
  errors: NonEmptyList(e),
) -> Result(b, NonEmptyList(e)) {
  case result {
    Ok(_) -> Error(errors)
    Error(existing_errors) ->
      Error(non_empty_list.append(existing_errors, errors))
  }
}

/// Build functions based on constructor arity
pub fn build1(constructor) {
  Ok(constructor)
}

pub fn build2(constructor) {
  Ok(curry2(constructor))
}

pub fn build3(constructor) {
  Ok(curry3(constructor))
}

/// `check` function for validating attributes
pub fn check(
  accumulator: ValidatorResult(fn(out) -> next_constructor, e),
  input: in,
  validator: Validator(in, out, e),
) -> ValidatorResult(next_constructor, e) {
  case validator(input) {
    Ok(out) -> result.map(accumulator, fn(acc) { acc(out) })
    Error(errors) -> add_errors(accumulator, errors)
  }
}
