import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

type Point {
  Point(x: Int, y: Int)
}

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/09.txt")
  let points = parse_input(input)
  io.println("part 1: " <> int.to_string(part1(points)))
}

fn parse_input(input: String) -> List(Point) {
  string.trim(input)
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    let assert Ok([x, y]) =
      string.split(line, on: ",") |> list.try_map(int.parse)
    Point(x:, y:)
  })
}

fn part1(points: List(Point)) -> Int {
  list.combination_pairs(points)
  |> list.map(fn(pair) {
    let #(a, b) = pair
    let x = int.absolute_value(a.x - b.x) + 1
    let y = int.absolute_value(a.y - b.y) + 1
    x * y
  })
  |> list.fold(0, int.max)
}
