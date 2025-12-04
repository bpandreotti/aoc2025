import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() -> Nil {
  let assert Ok(input) = simplifile.read(from: "inputs/04.txt")
  let #(array, w) = parse_input(input)
  io.println("part 1: " <> int.to_string(part1(array, w)))
  io.println("part 2: " <> int.to_string(part2(array, w)))
}

fn get(array: BitArray, w: Int, x: Int, y: Int) -> Int {
  let h = bit_array.byte_size(array) / w
  case x < 0 || x >= w || y < 0 || y >= h {
    True -> 0
    False ->
      case bit_array.slice(array, w * y + x, 1) {
        Ok(<<0>>) -> 0
        Ok(<<1>>) -> 1
        _ -> panic
      }
  }
}

fn neighbour_count(array: BitArray, w: Int, x: Int, y: Int) -> Int {
  // starting from up, going clockwise
  get(array, w, x, y - 1)
  + get(array, w, x + 1, y - 1)
  + get(array, w, x + 1, y)
  + get(array, w, x + 1, y + 1)
  + get(array, w, x, y + 1)
  + get(array, w, x - 1, y + 1)
  + get(array, w, x - 1, y)
  + get(array, w, x - 1, y - 1)
}

fn parse_input(input: String) -> #(BitArray, Int) {
  let lines = string.trim(input) |> string.split(on: "\n")
  let array =
    list.map(lines, fn(l) {
      string.to_graphemes(l)
      |> list.map(fn(c) {
        case c {
          "." -> <<0>>
          "@" -> <<1>>
          _ -> panic as "invalid input"
        }
      })
      |> bit_array.concat
    })
    |> bit_array.concat
  let line_size = bit_array.byte_size(array) / list.length(lines)
  #(array, line_size)
}

fn part1(array: BitArray, w: Int) -> Int {
  let h = bit_array.byte_size(array) / w
  list.range(0, h - 1)
  |> list.map(fn(y) {
    list.range(0, w - 1)
    |> list.filter(fn(x) { get(array, w, x, y) == 1 })
    |> list.map(neighbour_count(array, w, _, y))
    |> list.count(fn(n) { n < 4 })
  })
  |> list.fold(0, int.add)
}

fn iterate(array: BitArray, w: Int) -> #(BitArray, Int) {
  let combine = fn(a, b) {
    let #(array_a, count_a) = a
    let #(array_b, count_b) = b
    #(bit_array.append(array_a, array_b), count_a + count_b)
  }
  let h = bit_array.byte_size(array) / w
  list.range(0, h - 1)
  |> list.map(fn(y) {
    list.range(0, w - 1)
    |> list.map(fn(x) {
      case get(array, w, x, y) {
        0 -> #(<<0>>, 0)
        1 ->
          case neighbour_count(array, w, x, y) < 4 {
            False -> #(<<1>>, 0)
            True -> #(<<0>>, 1)
          }
        _ -> panic
      }
    })
    |> list.fold(#(<<>>, 0), combine)
  })
  |> list.fold(#(<<>>, 0), combine)
}

fn part2(array: BitArray, w: Int) -> Int {
  case iterate(array, w) {
    #(_, 0) -> 0
    #(new, n) -> n + part2(new, w)
  }
}
