import filepath
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import globlin
import globlin_fs
import simplifile

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
