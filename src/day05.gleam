import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Range {
  Range(from: Int, to: Int)
}

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/05.txt")
  let #(range, ids) = parse_input(input)
  io.println("part 1: " <> int.to_string(part1(range, ids)))
}

fn parse_input(input: String) -> #(List(Range), List(Int)) {
  let assert Ok(#(first, second)) = string.split_once(input, on: "\n\n")
  let assert Ok(ranges) =
    string.trim(first)
    |> string.split(on: "\n")
    |> list.try_map(fn(line) {
      case string.split(line, on: "-") {
        [a, b] -> {
          use a <- result.try(int.parse(a))
          use b <- result.try(int.parse(b))
          Ok(Range(from: a, to: b))
        }
        _ -> Error(Nil)
      }
    })

  let assert Ok(ids) =
    string.trim(second) |> string.split(on: "\n") |> list.try_map(int.parse)

  #(ranges, ids)
}

fn in_range(id: Int, range: Range) -> Bool {
  id >= range.from && id <= range.to
}

fn part1(ranges: List(Range), ids: List(Int)) -> Int {
  list.count(ids, fn(id) { list.any(ranges, in_range(id, _)) })
}
