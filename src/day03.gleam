import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) =
    simplifile.read(from: "inputs/03.txt") |> result.map(parse_input)

  let part1 = list.map(input, joltage(_, 2)) |> list.fold(0, int.add)
  io.println("part 1: " <> int.to_string(part1))

  let part2 = list.map(input, joltage(_, 12)) |> list.fold(0, int.add)
  io.println("part 1: " <> int.to_string(part2))
}

fn parse_input(input: String) -> List(List(Int)) {
  string.trim(input)
  |> string.split(on: "\n")
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
