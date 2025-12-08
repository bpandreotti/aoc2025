import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Point {
  Point(x: Int, y: Int, z: Int)
}

type Circuit {
  Circuit(find: Int, size: Int)
}

type UnionFind =
  dict.Dict(Int, Circuit)

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/08.txt")
  let points = parse_input(input)
  io.println("part 1: " <> int.to_string(part1(points, 1000)))
  io.println("part 2: " <> int.to_string(part2(points)))
}

fn parse_input(input: String) -> List(Point) {
  string.trim(input)
  |> string.split(on: "\n")
  |> list.map(fn(line) {
    let assert Ok([x, y, z]) =
      string.split(line, on: ",") |> list.try_map(int.parse)
    Point(x:, y:, z:)
  })
}

fn dist(a: Point, b: Point) -> Int {
  let x = a.x - b.x
  let y = a.y - b.y
  let z = a.z - b.z
  x * x + y * y + z * z
}

fn find(uf: UnionFind, p: Int) -> Circuit {
  let circ = dict.get(uf, p) |> result.unwrap(Circuit(find: p, size: 1))
  case circ.find == p {
    False -> find(uf, circ.find)
    True -> circ
  }
}

fn merge(uf: UnionFind, a: Int, b: Int) -> UnionFind {
  let ca = find(uf, a)
  let cb = find(uf, b)
  case ca.find == cb.find {
    False -> {
      let new_repr = case ca.size >= cb.size {
        True -> ca.find
        False -> cb.find
      }
      let merged = Circuit(new_repr, ca.size + cb.size)
      dict.insert(uf, ca.find, merged) |> dict.insert(cb.find, merged)
    }
    True -> uf
  }
}

fn circuit_sizes(uf: UnionFind) -> List(Int) {
  dict.to_list(uf)
  |> list.filter_map(fn(pair) {
    let #(k, v) = pair
    case k == v.find {
      False -> Error(Nil)
      True -> Ok(v.size)
    }
  })
}

fn point_pairs(points: List(Point)) -> List(#(#(Point, Int), #(Point, Int))) {
  list.index_map(points, fn(p, i) { #(p, i) })
  |> list.combination_pairs
  |> list.sort(fn(left, right) {
    let #(#(l1, _), #(l2, _)) = left
    let #(#(r1, _), #(r2, _)) = right
    int.compare(dist(l1, l2), dist(r1, r2))
  })
}

fn part1(points: List(Point), num_merges: Int) -> Int {
  point_pairs(points)
  |> list.take(num_merges)
  |> list.fold(dict.new(), fn(uf, merge_pair) {
    let #(#(_, a), #(_, b)) = merge_pair
    merge(uf, a, b)
  })
  |> circuit_sizes
  |> list.append(list.repeat(1, 3))
  |> list.sort(int.compare)
  |> list.reverse
  |> list.take(3)
  |> list.fold(1, int.multiply)
}

fn part2(points: List(Point)) -> Int {
  let num_points = list.length(points)
  let assert #(_, Ok(#(#(a, _), #(b, _)))) =
    point_pairs(points)
    |> list.fold_until(#(dict.new(), Error(Nil)), fn(acc, merge_pair) {
      let #(uf, _) = acc
      let #(#(_, a), #(_, b)) = merge_pair
      let new = merge(uf, a, b)
      case find(new, a).size == num_points {
        False -> list.Continue(#(new, Error(Nil)))
        True -> list.Stop(#(new, Ok(merge_pair)))
      }
    })
  a.x * b.x
}
