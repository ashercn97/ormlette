//// This is used to help run the output of `src/ormlette/query/query.sql()` output

import cake/param
import gleam/list
import gleam/pgo

pub fn param_to_value(v: param.Param) {
  case v {
    param.IntParam(value) -> pgo.int(value)
    param.BoolParam(value) -> pgo.bool(value)
    param.FloatParam(value) -> pgo.float(value)
    param.NullParam -> pgo.null()
    param.StringParam(value) -> pgo.text(value)
  }
}

pub fn run(sql: #(String, List(param.Param)), db: pgo.Connection, decoder) {
  let #(sql, params) = sql
  sql
  |> pgo.execute(db, list.map(params, param_to_value), decoder)
}
