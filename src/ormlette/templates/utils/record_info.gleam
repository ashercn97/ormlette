import argv
import gleam/bool
import gleam/dynamic
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import glerd/types
import simplifile
import sprinkle.{format}

pub fn find_records(records) {
  list.filter(records, fn(r) {
    let #(record_name, module_name, info, _) = r
    module_name == "eggs/decode"
  })
}

pub fn generate_to_dict(
  record_name: String,
  fields: List(#(String, types.FieldType)),
) -> String {
  let field_mappings =
    list.map(fields, fn(l) {
      let #(field_name, field_type) = l
      case field_type {
        types.IsString -> format("#(\"{0}\", u.{0})", [#("0", field_name)])
        types.IsInt ->
          format("#(\"{0}\", u.{0} |> int.to_string)", [#("0", field_name)])
        types.IsOption(inner_type) ->
          format("#(\"{0}\", u.{0} |> dynamic.from)", [#("0", field_name)])
        _ -> format("#(\"{0}\", u.{0})", [#("0", field_name)])
      }
    })
  format(
    "
  pub fn {0}_to_dict(u: decode.{2}) {{
    dict.from_list([
      {1}
    ])
  }}
  ",
    [
      #("0", string.lowercase(record_name)),
      #("1", string.join(field_mappings, ",\n")),
      #("2", record_name),
    ],
  )
}

pub fn optional_to_string(opt: option.Option(a)) -> String {
  case opt {
    option.None -> "None"
    option.Some(value) -> value |> dynamic.from |> wrap
  }
}

pub fn wrap(opt: dynamic.Dynamic) {
  case dynamic.classify(opt) {
    "String" -> "dynamic.from(" <> result.unwrap(dynamic.string(opt), "") <> ")"
    "Int" ->
      "dynamic.from("
      <> int.to_string(result.unwrap(dynamic.int(opt), 0))
      <> ")"
    "Bool" ->
      "dynamic.from("
      <> bool.to_string(result.unwrap(dynamic.bool(opt), True))
      <> ")"
    _ -> panic
  }
}

pub fn generate_all_to_dicts(
  records: List(#(String, String, List(#(String, types.FieldType)), String)),
  path: String,
) {
  list.fold(
    list.append(
      list.map(records, fn(l) {
        let #(record_name, _module, fields, _doc) = l
        generate_to_dict(record_name, fields)
      }),
      [
        "  import eggs/decode
  import gleam/dynamic
  import gleam/dict
  import gleam/int
  import gleam/io
  import gleam/option
  import gleam/string
  import ormlette/templates/utils/record_info as ri
",
      ],
    ),
    "",
    fn(a, b) { a <> b },
  )
  |> simplifile.write(to: path)
}
