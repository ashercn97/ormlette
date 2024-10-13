import non_empty_list
import ormlette_validate/valid

/// Validate that an integer meets a minimum value, with a custom error type
pub fn min(min: Int, error: e) -> valid.Validator(Int, Int, e) {
  fn(value: Int) {
    case value < min {
      True -> Error(non_empty_list.new(error, []))
      False -> Ok(value)
    }
  }
}
