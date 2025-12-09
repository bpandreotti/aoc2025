import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

type Point {
  Point(x: Int, y: Int)
}

type Bounds {
  Bounds(t: Int, b: Int, l: Int, r: Int)
}

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/09.txt")
  let points = parse_input(input)
  io.println("part 1: " <> int.to_string(part1(points)))
  io.println("part 2: " <> int.to_string(part2(points)))
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

fn area(rect: #(Point, Point)) -> Int {
  let #(a, b) = rect
  let x = int.absolute_value(a.x - b.x) + 1
  let y = int.absolute_value(a.y - b.y) + 1
  x * y
}

fn part1(points: List(Point)) -> Int {
  list.combination_pairs(points) |> list.map(area) |> list.fold(0, int.max)
}

fn bounds(rect: #(Point, Point)) -> Bounds {
  let #(a, b) = rect
  Bounds(
    t: int.min(a.y, b.y),
    b: int.max(a.y, b.y),
    l: int.min(a.x, b.x),
    r: int.max(a.x, b.x),
  )
}

fn is_outside(edge: #(Point, Point), rect: #(Point, Point)) -> Bool {
  let rect = bounds(rect)
  let edge = bounds(edge)
  edge.b <= rect.t || edge.t >= rect.b || edge.r <= rect.l || edge.l >= rect.r
}

fn part2(points: List(Point)) -> Int {
  let assert Ok(first) = list.first(points)
  let edges = list.append(points, [first]) |> list.window_by_2
  list.combination_pairs(points)
  |> list.filter(fn(rect) { list.all(edges, is_outside(_, rect)) })
  |> list.map(area)
  |> list.fold(0, int.max)
}
