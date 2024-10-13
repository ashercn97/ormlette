import gleam/option
import ormlette_validate/valid

/// Make a validator optional, only validating if the value is `Some`.
pub fn optional(
  inner_validator: valid.Validator(a, b, e),
) -> valid.Validator(option.Option(a), option.Option(b), e) {
  fn(value: option.Option(a)) {
    case value {
      option.None -> Ok(option.None)
      // If there's no value, return Ok(None)
      option.Some(inner_value) -> {
        // If there is a value, apply the inner validator
        case inner_validator(inner_value) {
          Ok(valid_value) -> Ok(option.Some(valid_value))
          // If inner validation is successful, wrap result in Some
          Error(error) -> Error(error)
          // If inner validation fails, pass through the error
        }
      }
    }
  }
}
