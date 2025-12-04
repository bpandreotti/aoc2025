import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/03.txt")
  io.println("part 1: " <> int.to_string(part1(input)))
  io.println("part 2: " <> int.to_string(part2(input)))
}

fn parse_input(input: String) -> List(List(Int)) {
  string.split(input, on: "\n")
  |> list.map(fn(line) {
    let assert Ok(line) = string.to_graphemes(line) |> list.try_map(int.parse)
    line
  })
}

fn select_one(bank: List(Int), upto: Int) -> List(Int) {
  case upto {
    0 -> panic
    1 -> bank
    n -> {
      let assert [x, ..xs] = bank
      let assert [y, ..ys] = select_one(xs, n - 1)
      case x >= y {
        True -> bank
        False -> [y, ..ys]
      }
    }
  }
}

fn select_batteries(bank: List(Int), batteries: Int) -> List(Int) {
  case batteries {
    0 -> []
    _ -> {
      let assert [b, ..rest] =
        select_one(bank, list.length(bank) - batteries + 1)
      [b, ..select_batteries(rest, batteries - 1)]
    }
  }
}

fn joltage(bank: List(Int), batteries: Int) -> Int {
  select_batteries(bank, batteries) |> list.fold(0, fn(acc, x) { acc * 10 + x })
}

fn part2(input: String) -> Int {
  parse_input(string.trim(input))
  |> list.map(joltage(_, 12))
  |> list.fold(0, int.add)
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
