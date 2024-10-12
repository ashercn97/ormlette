//// This is the CLI tool's entry point
//// TO use it, just run `gleam run -m ormlette` in your project, with the schema in the `src/schema` folder, named with the following rules:
//// * File name = table name
//// * A function named {table_name}_table that returns a table object
////

import argv
import clip
import clip/opt
import gleam/io
import gleam/result
import ormlette/changesets/changesets
import ormlette/cli/generate
import shellout
import simplifile

/// Type of the commands. This will grow! Liuke there will be more
/// gen.meta is for the metadata of the records, (THANKS GLERD)
/// gen.orm is for the decoders, types, etc.
type Gen {
  Meta
  Orm
}

/// This is for the Meta part
fn meta_command() {
  clip.return(Meta)
  |> clip.add_help(
    "gen meta",
    "Generates metadata for Records using Glerd. Makes it so we can have proper __ FORGET NAME RN",
  )
}

/// This is for the Orm part
///
fn orm_command() {
  clip.return(Orm)
  |> clip.add_help(
    "gen orm",
    "Generates the ORM decoders, types, and access types. RUN BEFORE gen meta",
  )
}

/// Main command
///
fn command() {
  clip.subcommands([#("meta", meta_command()), #("orm", orm_command())])
}

/// Main CLI args
///
pub fn main() {
  let result =
    command()
    |> clip.add_help("gen", "Run some codegen!")
    |> clip.run(argv.load().arguments)

  case result {
    Error(e) -> io.println_error("ERR" <> e)
    Ok(args) -> {
      let results = case args {
        Orm -> {
          generate.create_generate_file()
          run_module("eggs/generate")
          io.println("Ran module eggs/generate")
        }
        Meta -> {
          run_module("glerd")
          io.println("Ran module glerd")
        }
      }
      // io.debug(results)
      io.println("Done!")
    }
  }
}

/// This runs the generated file with gleam to actually create the necesary files
///
pub fn run_module(mod: String) {
  let assert Ok(cwd) = simplifile.current_directory()
  case shellout.command("gleam", ["run", "-m", mod], in: cwd <> "/", opt: []) {
    Ok(_) -> {
      // io.println("Successfully generated types and decoders.")
      Ok(Nil)
    }
    Error(_) -> {
      // io.debug("Error generating types and decoders")
      Error(Nil)
    }
  }
}
