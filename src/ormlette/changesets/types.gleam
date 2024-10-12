import gleam/dict
import gleam/dynamic
import ormlette/schema/create as c

pub type ValidationError {
  RequiredField(String)
  // Field is required but not provided
  InvalidFormat(String)
  // Field does not meet a specific format requirement
  ForeignKeyConstraint(String)
  // Foreign key constraint is violated
  CustomError(String, String)
  // Custom validation error
}

pub type Changeset {
  Changeset(
    table: c.Table,
    data: dict.Dict(String, dynamic.Dynamic),
    errors: List(ValidationError),
  )
}
