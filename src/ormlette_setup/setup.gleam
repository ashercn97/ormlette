import dot_env as dot
import dot_env/env
import gleam/io
import gleam/result
import ormlette/templates/utils/to_string
import ormlette_setup/templates/db
import ormlette_setup/types.{type DbInfo, DbInfo}
import simplifile

pub fn run() {
  dot.load_default()
  let info =
    result.unwrap(
      {
        use user <- result.try(env.get_string("user"))
        use pass <- result.try(env.get_string("pass"))
        use db <- result.try(env.get_string("database"))
        Ok(DbInfo(user, pass, "localhost", db))
      },
      DbInfo("postgres", "postgres", "localhost", "postgres"),
    )

  let assert Ok(cwd) = simplifile.current_directory()
  db.render(info)
  |> to_string.to_file(
    path: cwd <> "/src/eggs/db.gleam",
    style: to_string.Write,
  )
  Nil
}
