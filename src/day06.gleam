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
  let problems = parse_input(input)
  io.println("part 1: " <> int.to_string(part1(problems)))
}

fn parse_input(input: String) -> List(Problem) {
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
}

fn part1(input: List(Problem)) -> Int {
  list.map(input, fn(p) {
    case p.op {
      Add -> list.fold(p.args, 0, int.add)
      Mul -> list.fold(p.args, 1, int.multiply)
    }
  })
  |> list.fold(0, int.add)
}
