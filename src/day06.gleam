import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

type Op {
  Add
  Mul
}

type Problem {
  Problem(op: Op, args: List(Int))
}

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/06.txt")
  io.println("part 1: " <> int.to_string(part1(input)))
  io.println("part 2: " <> int.to_string(part2(input)))
}

fn solve(input: List(Problem)) -> Int {
  list.map(input, fn(p) {
    case p.op {
      Add -> list.fold(p.args, 0, int.add)
      Mul -> list.fold(p.args, 1, int.multiply)
    }
  })
  |> list.fold(0, int.add)
}

fn part1(input: String) -> Int {
  string.trim(input)
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    string.split(line, on: " ") |> list.filter(fn(s) { !string.is_empty(s) })
  })
  |> list.transpose
  |> list.map(fn(prob) {
    case list.reverse(prob) |> list.split(1) {
      #([op], args) -> {
        let op = case op {
          "+" -> Add
          "*" -> Mul
          _ -> panic as "unknown op"
        }
        let assert Ok(args) = list.try_map(args, int.parse)
        Problem(op:, args:)
      }
      #(_, _) -> panic as "invalid input"
    }
  })
  |> solve
}

fn parse_columns(columns: List(List(String))) -> List(List(Int)) {
  let #(first, rest) =
    list.split_while(columns, list.any(_, fn(c) { c != " " }))
  io.println(string.inspect(first))
  let assert Ok(first) =
    list.try_map(first, fn(column) {
      string.concat(column) |> string.trim |> int.parse
    })
  case rest {
    [] -> [first]
    [_, ..rest] -> [first, ..parse_columns(rest)]
  }
}

fn part2(input: String) -> Int {
  let lines = string.trim(input) |> string.split(on: "\n")
  let assert #(columns, [ops]) = list.split(lines, list.length(lines) - 1)
  let args =
    list.map(columns, string.to_graphemes) |> list.transpose |> parse_columns
  let ops =
    string.split(ops, on: " ")
    |> list.filter(fn(s) { !string.is_empty(s) })
    |> list.map(fn(op) {
      case op {
        "+" -> Add
        "*" -> Mul
        _ -> panic as "unknown op"
      }
    })
  let problems =
    list.zip(ops, args)
    |> list.map(fn(pair) {
      let #(op, args) = pair
      Problem(op:, args:)
    })
  solve(problems)
}
