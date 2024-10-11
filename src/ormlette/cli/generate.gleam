///// This uses a matcha template to generate a file that will be used to generate the schema files.
////

import filepath
import gleam/io
import gleam/option
import ormlette/cli/schema
import ormlette/templates/generate
import ormlette/templates/utils/to_string
import simplifile

pub fn create_generate_file() {
  let schema_files = option.unwrap(schema.find_schema_files(), [])
  io.debug(schema_files)
  schema_files
  |> generate.render
  |> to_string.to_file("./src/eggs/generate.gleam", to_string.Write)
}
