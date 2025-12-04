import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/03.txt")
  io.println("part 1: " <> int.to_string(part1(input)))
}

fn parse_input(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> list.map(fn(line) {
    let assert Ok(line) = string.to_graphemes(line) |> list.try_map(int.parse)
    line
  })
}

fn max_list(xs: List(Int)) -> List(Int) {
  case xs {
    [] -> []
    [x, ..xs] -> {
      let ml = max_list(xs)
      let max = int.max(x, list.first(ml) |> result.unwrap(0))
      [max, ..ml]
    }
  }
}

fn bank_joltage(bank: List(Int), max_list: List(Int)) -> Int {
  case bank, max_list {
    [], _ -> panic as "unreachable"
    [_, _, ..], [] -> panic as "unreachable"
    [_], [] -> 0
    [b, ..bs], [m, ..ms] -> {
      int.max(10 * b + m, bank_joltage(bs, ms))
    }
  }
}

fn part1(input: String) -> Int {
  parse_input(string.trim(input))
  |> list.map(fn(bank) {
    let assert Ok(ml) = max_list(bank) |> list.rest
    bank_joltage(bank, ml)
  })
  |> list.fold(0, int.add)
}
