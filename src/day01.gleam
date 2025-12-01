import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/01.txt")
  io.println("part 1: " <> int.to_string(part1(input)))
  io.println("part 2: " <> int.to_string(part2(input)))
}

fn parse_input(input: String) -> List(Int) {
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
}

fn part1(input: String) -> Int {
  parse_input(input)
  |> list.fold([50], fn(xs, x) {
    case xs {
      [head, ..] -> [{ x + head } % 100, ..xs]
      [] -> panic
    }
  })
  |> list.count(fn(x) { x == 0 })
}

fn count_zeros(position: Int, movements: List(Int)) -> Int {
  case movements {
    [move, ..rest] -> {
      // In general, the dial will pass zero every full turn we complete
      let new = position + move
      let zeros = int.absolute_value(new / 100)

      // If the position is not at zero, and the dial passes zero going to the
      // left, we will have missed this extra zero.
      // E.g. if the dial is at 10, and moves -20, `zeros` will be -10/100 = 0
      let extra = case position > 0 && new <= 0 {
        True -> 1
        False -> 0
      }

      let assert Ok(new) = int.modulo(new, by: 100)
      zeros + extra + count_zeros(new, rest)
    }
    [] -> 0
  }
}

fn part2(input: String) -> Int {
  count_zeros(50, parse_input(input))
}
