//// This module is responsible for finding all the schema files in the project.
//// It uses the `globlin` and `globlin_fs` libraries to find all the files in the `src/schema` directory.
//// It then strips the file extension and returns the list of schema names.

import filepath
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import globlin
import globlin_fs
import simplifile

/// Main function. Just finds the things, see module description.
pub fn find_schema_files() {
  let assert Ok(cwd) = simplifile.current_directory()

  let assert Ok(pattern) = globlin.new_pattern(cwd <> "/src/schema/*.gleam")

  case globlin_fs.glob(pattern, returning: globlin_fs.RegularFiles) {
    Ok(files) -> {
      files
      |> list.sort(string.compare)
      |> list.map(filepath.base_name)
      |> list.map(filepath.strip_extension)
      |> option.Some
    }
    Error(err) -> {
      io.print("File error: ")
      io.debug(err)
      option.None
    }
  }
}
