import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/01.txt")
  io.println(int.to_string(part1(input)))
}

fn part1(input: String) -> Int {
  string.split(input, on: "\n")
  |> list.filter(fn(l) { !string.is_empty(l) })
  |> list.map(fn(line) {
    let assert Ok(value) = case line {
      "R" <> x -> int.parse(x)
      "L" <> x -> int.parse(x) |> result.map(fn(x) { -x })
      _ -> panic as "incorrect input"
    }
    value
  })
  |> list.fold([50], fn(xs, x) {
    case xs {
      [head, ..] -> [{ x + head } % 100, ..xs]
      [] -> panic
    }
  })
  |> list.count(fn(x) { x == 0 })
}
