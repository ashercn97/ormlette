//// This is the CLI tool's entry point
//// TO use it, just run `gleam run -m ormlette` in your project, with the schema in the `src/schema` folder, named with the following rules:
//// * File name = table name
//// * A function named {table_name}_table that returns a table object
////

import gleam/io
import ormlette/cli/generate
import shellout
import simplifile

/// Creates the `src/eggs` directory and adds the files. Pretty cool! :)
///
pub fn main() {
  generate.create_generate_file()
  gleam_run()
}

/// This runs the generated file with gleam to actually create the necesary files
///
pub fn gleam_run() {
  let assert Ok(cwd) = simplifile.current_directory()
  case
    shellout.command(
      "gleam",
      ["run", "-m", "eggs/generate"],
      in: cwd <> "/",
      opt: [],
    )
  {
    Ok(_) -> {
      io.println("Successfully generated types and decoders.")
      Ok(Nil)
    }
    Error(_) -> {
      io.debug("Error generating types and decoders")
      Error(Nil)
    }
  }
}
